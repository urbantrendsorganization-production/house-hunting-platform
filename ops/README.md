# ops — Deploy & infrastructure (Phase 7)

Production deploy, backups, monitoring, and load testing for Keja on Hetzner
behind Caddy. Local dev still uses the root `docker-compose.yml`, not this dir.

```
ops/
├── compose/docker-compose.prod.yml   # prod stack (GHCR image, gunicorn, beat, Caddy)
├── caddy/Caddyfile                   # reverse proxy + automatic TLS
├── env/prod.env.example              # prod env shape (placeholders only)
├── backup/                           # pg_dump backup + restore scripts (+ rehearsal)
└── loadtest/                         # viewport load test (stdlib harness + k6)
```

## Deploy

```bash
cd ops/compose
cp ../env/prod.env.example .env      # fill with REAL secrets — never commit .env
docker compose -f docker-compose.prod.yml up -d
```

Caddy fetches TLS certs for `$API_DOMAIN` / `$WEB_DOMAIN` automatically. Only
80/443 face the internet; Postgres and Redis stay on the internal network.
Persistent state lives under `/srv/keja` (pgdata, redisdata, caddy, backups).

## Backups

`backup/backup.sh` (nightly cron) + `backup/restore.sh`. **Rehearse the restore**
monthly — see [`backup/README.md`](./backup/README.md). This satisfies the
Phase 7 restore-from-backup gate.

## Monitoring

- **Health:** `GET /api/v1/health/` (DB + PostGIS) and Caddy's `/healthz` for
  cheap uptime probes.
- **Slow requests:** `SlowRequestLoggerMiddleware` logs any request over
  `SLOW_REQUEST_MS` (default 500ms) to the `keja.slow` logger.
- **Errors:** set `SENTRY_DSN` (Sentry or self-hosted GlitchTip) — the SDK is a
  no-op when unset.

## Load testing

`loadtest/viewport_loadtest.py` (stdlib) or `loadtest/viewport.k6.js` (k6) — the
"50x pilot traffic" gate. See [`loadtest/README.md`](./loadtest/README.md); raise
the anon throttle and measure against gunicorn, not the dev server.

## Remaining (human / field gates)

- Two estates live with < 10% listings older than 7 days verification age.
- A non-founder agent captures buildings with zero hand-holding after onboarding.
