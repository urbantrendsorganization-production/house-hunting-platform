# CLAUDE.md — Keja

> Working name: **Keja** (sheng for "house"). Rename is a find-and-replace away.

## What this is

Keja is a location-first house-hunting platform for Kenya. A user opens the app, we detect their location (or they search one), and the map shows **verified vacant units** around them — Bolt-style precision, real gate-level pins, with a "verified X days ago" freshness badge on every listing.

The moat is not the map. The moat is the **data pipeline**: field agents physically visit buildings, pin them at the gate, and record per-unit-type vacancy counts. Vacancy data rots in days, so the entire system is architected around **freshness** — capture, verify, demote, expire.

## The three surfaces

1. **Agent app (Flutter, offline-first)** — field agents capture buildings, units, photos, vacancies. Works without network; syncs when online.
2. **Consumer app (Flutter) + website (Next.js)** — map-first discovery. Open → locate → see vacant houses → tap → details → contact/directions.
3. **Back office (Next.js, admin)** — agent management, data QA, listing moderation, staleness dashboards.

## Stack

| Layer | Choice | Why |
|---|---|---|
| API | Django 5 + DRF + **GeoDjango** | Mature geospatial ORM; `dwithin`/bbox queries are one-liners |
| DB | PostgreSQL 16 + **PostGIS 3.4** | Spatial indexing (GiST), the industry standard |
| Cache | Redis | Viewport tile cache, hot listings, rate limiting |
| Jobs | Celery + Redis broker | Staleness sweeps, media processing, notifications |
| Agent app | Flutter + Drift (local queue) | Offline-first capture, same pattern as OnboardKit |
| Consumer app | Flutter + Google Maps SDK | Free map loads on mobile SDKs; best Kenya map data |
| Website | Next.js 15 + TypeScript + Maps JS API | SEO for "vacant houses in Kilimani" queries |
| Media | S3-compatible object storage, presigned uploads | Client uploads direct; API never proxies bytes |
| Auth | SimpleJWT (consumers), agent accounts with device binding | Reuse RentFlow auth patterns |
| Deploy | Docker Compose + Caddy + GitHub Actions + GHCR → Hetzner | Existing UrbanTrends infra, zero new ops |

**Deliberately NOT using:** Mapbox (weaker Kenya data), microservices (premature), Rust (see below), Elasticsearch (PostGIS + pg full-text is enough for years).

**Rust escape hatch:** if `/api/v1/map/viewport` ever becomes a measured bottleneck, extract it into a read-only Axum service against the same PostGIS db. Do not do this preemptively.

## Domain model (core)

```
Estate            # named area: "Roysambu", "Kilimani" — polygon or centroid
Building          # THE anchor entity
  ├─ location     # PointField, SRID 4326, captured AT THE GATE by agent GPS
  ├─ name, photos, floors, water/power notes, security, parking
  ├─ caretaker_name, caretaker_phone (E.164)
  ├─ estate FK, created_by_agent FK
UnitType          # per building: BEDSITTER / 1BR / 2BR / ... 
  ├─ rent_kes, deposit_kes, amenities JSONB, photos
VacancySnapshot   # append-only — the freshness engine
  ├─ unit_type FK, vacant_count, verified_at, verified_by (agent FK)
  ├─ source: AGENT_VISIT | CARETAKER_CALL | CARETAKER_SELF_REPORT
Agent             # field agent, device-bound, coverage estates
Lead              # consumer expressed interest (business model hook — keep generic)
```

**Rules that must never be violated:**
- `VacancySnapshot` is **append-only**. Current vacancy = latest snapshot per unit type. Never UPDATE a snapshot. (Same append-only discipline as OnboardKit's event state machine.)
- Every listing surface shows `verified_at` age. Listings with latest snapshot **> 14 days old are demoted**; **> 30 days hidden**. Celery sweep enforces this hourly.
- `Building.location` is only writable by agent capture or admin correction — never by consumer input.
- Phone numbers normalized to E.164 at the boundary (reuse the OTP module's normalizer).

## Geo query patterns (the heart of the API)

```python
# Viewport query (map pan) — bbox from client
Building.objects.filter(
    location__within=Polygon.from_bbox((w, s, e, n)),
    has_active_vacancy=True,          # denormalized flag, maintained by sweep
)[:MAX_MARKERS]

# Radius query ("near me")
Building.objects.filter(
    location__dwithin=(user_point, D(km=2)),
    has_active_vacancy=True,
).annotate(dist=Distance("location", user_point)).order_by("dist")
```

- GiST index on `Building.location`. Always.
- `has_active_vacancy` is a denormalized boolean on Building, recomputed by the staleness sweep and on snapshot insert. Viewport queries must never join through snapshots.
- Cluster markers **server-side** above zoom threshold (grid-snap via `ST_SnapToGrid`) — never send 500 markers to a phone.
- Cache viewport responses in Redis keyed by quantized bbox + zoom, TTL 60s.

## API conventions

- Versioned: `/api/v1/...`
- Consumer endpoints are **anonymous-readable** (browsing needs no account); leads/contact reveal require auth (business model hook).
- Agent endpoints require agent JWT + device binding.
- Sync endpoint for agent app is **idempotent**: client sends `client_uuid` per record; server upserts. Offline queues cause retries — duplicates are a bug in our design, not the agent's problem.
- Photos: client requests presigned PUT → uploads direct to object storage → confirms key to API. API never touches image bytes. Celery generates thumbnails.

## Google Maps cost discipline

- Mobile: Maps SDK loads are free — use natively.
- Web: cache geocode results in Postgres permanently (geocoding the same estate twice is a bug).
- Places Autocomplete: session tokens + debounce ≥ 300ms + restrict `components=country:ke`.
- Never call Places/Geocoding from a loop or on map pan.

## Agent app rules

- **Offline-first is not optional.** All capture writes to local Drift db first; a sync worker drains the queue. UI must never block on network.
- GPS capture: require accuracy ≤ 15m before allowing pin save; show accuracy circle; agent physically stands at the gate.
- Photos compressed client-side (max ~1600px long edge) before queueing.
- Every capture stamped with `agent_id`, `device_id`, `captured_at`, raw GPS accuracy — this is our data QA trail.

## Code style & workflow

- Python: ruff + black defaults, type hints on all service-layer functions.
- Django: business logic in `services/` modules, not views, not models. Thin serializers.
- Flutter: Riverpod for state, repository pattern over the local db + API client.
- TS/Next: strict mode, no `any`, server components by default.
- Tests: pytest; every geo query pattern gets a test with real PostGIS fixtures (not mocks). Sync idempotency has dedicated tests.
- Conventional commits. PRs against `main`, CI must pass (lint, test, build).
- Secrets: never in repo, never in `.env.example` with real values (we learned this the hard way). Use placeholder values only.

## Environments

- `local`: docker compose (postgis, redis, api, minio for S3)
- `staging`: HP EliteOne home server via Tailscale
- `prod`: Hetzner, Compose + Caddy, GHCR images via GitHub Actions

## What "done" means for any feature

1. Works offline where relevant (agent app).
2. Has tests for the failure path, not just the happy path.
3. Respects the freshness rules (no surface ever shows a listing without `verified_at` age).
4. No new external SaaS dependency without discussion.