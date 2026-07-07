# Keja — location-first house-hunting for Kenya

A user opens the app, we detect their location, and the map shows **verified vacant
units** around them — Bolt-style precision, gate-level pins, with a "verified X days
ago" freshness badge on every listing. The moat is the **data pipeline**: field
agents physically visit buildings and record per-unit-type vacancy counts, and the
whole system is architected around freshness (capture → verify → demote → expire).

See [`CLAUDE.md`](./CLAUDE.md) for architecture and [`PLAN.md`](./PLAN.md) for the
phase-gated roadmap. Progress against the plan is tracked in
[`PROGRESS.md`](./PROGRESS.md).

## Monorepo layout

| Path | What | Status |
|---|---|---|
| `api/` | Django 5 + DRF + GeoDjango + PostGIS | **Phases 0/1/3 done, tested** |
| `agent_app/` | Flutter offline-first capture app | scaffold (Phase 2) |
| `consumer_app/` | Flutter map discovery app | scaffold (Phase 4) |
| `web/` | Next.js 15 website (SEO) | scaffold (Phase 5) |
| `ops/` | Deploy configs (Caddy, backups) | scaffold (Phase 7) |

## Quickstart (local)

```bash
docker compose up -d db redis            # Postgres/PostGIS + Redis
docker compose run --rm api python manage.py migrate
docker compose run --rm api python manage.py seed_demo --fresh
docker compose up -d api                 # http://localhost:8000
curl http://localhost:8000/api/v1/health/
```

Full stack (adds minio object storage + celery worker):

```bash
docker compose up -d
```

Host ports are offset (`db:5433`, `redis:6380`, `minio:9010/9011`) so Keja coexists
with other local UrbanTrends stacks. Container-internal ports are unchanged.

## Tests

```bash
docker compose run --rm api pytest
```

Geo queries and sync idempotency run against **real PostGIS** (not mocks), per the
project test policy.

## Key API surfaces

- `GET  /api/v1/health/` — liveness + PostGIS check
- `POST /api/v1/agent/login/` — agent JWT (device-bound)
- `POST /api/v1/agent/sync/` — idempotent offline-sync batch upsert
- `POST /api/v1/agent/photos/presign/` — presigned direct-to-S3 upload URL
- `GET  /api/v1/map/viewport/?w=&s=&e=&n=&zoom=` — markers / server-side clusters
- `GET  /api/v1/map/near-me/?lng=&lat=&radius_km=` — distance-sorted "near me"
- `GET  /api/v1/buildings/<uuid>/` — building detail (hidden listings 404)
