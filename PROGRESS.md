# PROGRESS.md — Keja build status

Tracks the phase-gated plan in [`PLAN.md`](./PLAN.md). "Gate met" means the phase's
gate was verified by an automated test or a live run, not just written.

## ✅ Phase 0 — Foundations — **gate met**

- Monorepo scaffold (`api/`, `agent_app/`, `consumer_app/`, `web/`, `ops/`).
- Docker Compose: `postgis:16-3.4`, `redis`, `api`, `minio` (+ bucket setup), `worker`.
- Django 5 + DRF + GeoDjango wired to PostGIS; `/api/v1/health/` returns PostGIS version.
- Core migrations: `Estate`, `Building`, `UnitType`, `VacancySnapshot`, `Agent` (+ `Lead`,
  `BuildingPhoto`), GiST index on `Building.location` (geography, SRID 4326).
- Seed: 3 estates, 20 buildings with real Nairobi coordinates.
- CI (`.github/workflows/ci.yml`): ruff + black + migration check + pytest against a
  PostGIS service, then a build-and-push of the API image to GHCR on `main`.

**Verified:** `docker compose up` serves a working API; a `dwithin` query returns
correct distance-sorted results in a test.

## ✅ Phase 1 — Agent capture pipeline (API) — **gate met**

- Agent JWT auth with **device binding** (first login binds; other devices rejected).
- Idempotent **sync** endpoint: batch of `client_uuid`-stamped records; upsert; per-record
  result. **Replaying a batch 5× produces identical DB state (test-proven).**
- E.164 phone normalization at the boundary (`services/phone.py`).
- Freshness engine (`services/freshness.py`): snapshot append recomputes
  `has_active_vacancy` / `is_demoted` / `latest_verified_at`.
- Celery **staleness sweep** (hourly beat): demote >14d, hide >30d.
- Presigned photo flow: **verified end-to-end against minio, bytes never touch the API.**

**Verified:** live login→sync→presign→PUT→read-back round trip; sweep demote/hide tests.

## ✅ Phase 3 — Consumer map API — **gate met**

- Anonymous-readable: `map/viewport` (bbox), `map/near-me` (radius), `buildings/<uuid>`.
- Server-side clustering via `ST_SnapToGrid` above a zoom threshold; markers capped at
  `MAP_MAX_MARKERS`.
- Redis viewport cache (quantized bbox+zoom key, 60s TTL).
- `verified_days_ago` on every listing.
- Abuse guards: anon throttling + max-bbox-area cap (422).

**Verified:** stale/hidden buildings provably absent from all consumer responses (tests);
clusters kick in when zoomed out; live smoke over seeded data.

> Note: the gate's *p95 latency on staging hardware* target is a measurement to take on
> real staging, not something reproducible in this dev container.

## 🟡 Phase 5 — Website (Next.js) — **built, SSR gate verified**

- Next.js 15 App Router, TypeScript strict, server components by default.
- Homepage (estates + live counts), **SSR/SSG estate pages** at
  `/vacant-houses/[estate]` with ItemList JSON-LD and verified-age badges, building
  detail with a Google Maps directions deep-link, and a viewport-driven `/map`
  (debounced refetch, server-side clusters) that degrades to a list without a Maps key.
- `robots.txt` + `sitemap.xml` (estate URLs).
- Backend support: `GET /estates/` and `/estates/<slug>/` (tested).

**Verified:** `npm run typecheck` + `npm run build` pass; estate/building content
renders in raw server HTML (JS-disabled equivalent) against the live API; JSON-LD and
sitemap present.

**Remaining (human/measurement gates):** Lighthouse ≥ 90 on real hosting; the
"5 strangers find a house" usability test; a real Google Maps JS API key for the map.

## ✅ Phase 6 — Back office + data QA — **gate met**

- **Duplicate detection** (`services/duplicates.py`): candidate pairs via spatial
  proximity (`dwithin`, GiST-indexed) + fuzzy name similarity, de-duplicated and
  closest-first. Proximity/name thresholds tunable per request.
- **Merge tool**: folds a source building into a target and deletes the source
  **without losing a single snapshot, photo, or lead** — same-kind unit types fold
  (children re-parented before delete), new kinds re-parent wholesale, then freshness
  is recomputed on the survivor. Every merge writes a read-only `BuildingMergeLog`.
- **Staleness dashboard** (`services/qa.py`): per-estate health (active / demoted /
  stale / hidden / never-verified counts + oldest & newest verification), **stalest
  estate first**; plus a stalest-buildings work queue (never-verified first).
- **Agent leaderboard**: buildings captured + verifications per agent (agent-payment hook).
- **Capture review queue** + **photo moderation** (`reviewed_at`/`reviewed_by` on
  Building, `rejected` on BuildingPhoto). Review is a data-quality trail, never a
  visibility switch — freshness still owns what consumers see.
- Staff-only API under `/api/v1/admin/…` (Django staff auth; **never** anonymous-readable).
  Django admin hardened: append-only snapshots, read-only merge log.

**Verified:** merge preserves snapshots/photos/leads (test-proven, nothing dropped);
dashboard ranks the stalest estate first and flags hidden listings; leaderboard counts
captures; back-office endpoints reject anonymous + non-staff callers. Full suite green.

## 🟡 Phase 7 — Pilot hardening & scale-out — **infra built, restore gate met**

Everything code-buildable for prod is done; what remains is field/infra work.

- **Prod deploy** (`ops/compose/docker-compose.prod.yml` + `ops/caddy/Caddyfile`):
  GHCR image, gunicorn, a dedicated celery-beat (the hourly sweep), Caddy TLS
  termination, DB/Redis off the public network, state under `/srv/keja`.
- **Backups** (`ops/backup/`): `pg_dump` (custom format) + optional object-storage
  mirror with retention; `restore.sh` drops/recreates and smoke-checks PostGIS.
- **Monitoring:** env-gated Sentry/GlitchTip (no-op when unset), a
  `SlowRequestLoggerMiddleware` (>`SLOW_REQUEST_MS` → `keja.slow`), optional SQL
  logging, and production security settings (HSTS, secure cookies, SSL redirect,
  proxy SSL header for Caddy). Caddy `/healthz` for uptime probes.
- **Load test** (`ops/loadtest/`): stdlib viewport harness (p50/p95/p99, status
  buckets) + a k6 ramp script for the "50x pilot traffic" gate.

**Verified:** backup → restore **rehearsed against a live db** — dump taken, db
dropped/recreated, restored, PostGIS 3.4.3 and all 20 buildings back (restore
gate met). Load harness runs and cleanly separates 429-throttle from server
errors. Full suite green (47), ruff + black clean.

**Remaining (human / field / infra gates):** deploy on real Hetzner + domains;
two estates live with < 10% listings older than 7 days; a non-founder agent
captures with zero hand-holding; measured p95 / 50x load on staging hardware.

## 🟡 Phase 2 — Agent app (Flutter, offline-first) — **built, analyzer + unit tests green**

- Riverpod + repository pattern over a **Drift local db (the offline source of
  truth)** and a Dio API client (CLAUDE.md stack).
- Device-bound phone login; capture flow with a **GPS accuracy gate** (pin locked
  until ≤ 15m, accepted fix frozen); building + unit-type + vacancy + photo forms;
  client-side photo compression.
- **Idempotent sync worker**: uploads photo bytes to object storage first (bytes
  never touch the API), then POSTs a dependency-ordered `client_uuid` batch to
  `/agent/sync/`; connectivity-driven, retries converge with zero duplicates.
- "My buildings" list with live per-record sync status + a **2-tap re-verify**
  sheet (the daily loop).

**Verified:** `flutter analyze` clean; unit tests prove capture queues as pending,
re-verify is append-only, and synced records leave the queue.
**Remaining (device/field gates):** airplane-mode capture→reconnect on a real
device; hand-capture a whole pilot estate.

## 🟡 Phase 4 — Consumer app (Flutter) — **built, analyzer + unit tests green**

- Riverpod; **Google Maps SDK** with markers + **server-side clusters** from the
  viewport API, debounced pan refetch, "near me" via fused location.
- Tap → bottom sheet: unit types + prices, **"Verified X days ago"** badge,
  Google Maps **directions deep-link**, interest/lead stub (endpoint deferred).
- KE-restricted **Places autocomplete** (session tokens, ≥300ms debounce);
  freshness/quality filters; a **list-view fallback** for no-key / low-end devices.

**Verified:** `flutter analyze` clean; unit tests cover both viewport modes,
building-detail parsing, and the freshness filter.
**Remaining (device/field gates):** cold-open < 5s on a mid-range Android; the
"5 strangers find a house" test; pan/zoom feel on a Tecno/Infinix-class phone.

> Note: price / unit-type filtering needs a small backend follow-up (denormalized
> `min_rent` / `unit_kinds` on the viewport payload); current filters use the
> verification age + demoted flag the marker payload already carries.

## Suggested next step

All seven phases are code-complete. What's left is **field + infra**: deploy on
Hetzner, put both apps on real devices, hand-capture a pilot estate, and run the
two "5 strangers / non-founder agent" gates. No further build work is blocked.
