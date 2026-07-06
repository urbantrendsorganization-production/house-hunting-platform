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

## ⏳ Remaining phases — need human / device / infra involvement

These are scaffolded (directory + README) but not built here, because their gates
require things outside an automated backend build:

- **Phase 2 — Agent app (Flutter):** gate is "capture a building in airplane mode, sync
  with zero data loss" and "capture a whole pilot estate by hand" — needs a real device
  and field work. The API it targets (`/agent/sync`, presign) is done and live.
- **Phase 4 — Consumer app (Flutter):** gate needs a mid-range Android device + 5 real
  house-hunter testers. Consumes the finished map API.
- **Phase 5 — Website (Next.js):** buildable next; gate needs SSR verification + Lighthouse.
- **Phase 6 — Back office / QA:** Django admin is already hardened (append-only snapshots,
  read-only vacancy history). Duplicate-merge tooling + dashboards remain.
- **Phase 7 — Prod hardening:** needs Hetzner/Tailscale access, real domains, backups.

## Suggested next step

Build **Phase 5 (web)** — it's the next fully code-buildable surface and gives a real
end-to-end user-facing experience on top of the finished map API.
