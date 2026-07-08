# ops — Deploy & infrastructure (Phase 7)

Production deploy, backups, monitoring, and load testing for Keja on the shared
UrbanTrends host. Local dev still uses the root `docker-compose.yml`, not this dir.

```
ops/
├── compose/docker-compose.prod.yml   # prod stack (GHCR api image, gunicorn, beat, web)
├── caddy/keja.hostcaddy.snippet      # vhosts to add to the shared HOST Caddy
├── caddy/Caddyfile                   # standalone self-TLS variant (solo deploy only)
├── env/prod.env.example              # prod env shape (placeholders only)
├── backup/                           # pg_dump backup + restore scripts (+ rehearsal)
└── loadtest/                         # viewport load test (stdlib harness + k6)
```

## Deploy

The prod box already runs a **host-level Caddy** owning `:80/:443` for the other
UrbanTrends stacks, so keja does **not** run its own Caddy. The stack publishes
`api` and `web` on loopback ports and the host Caddy fronts them + does TLS.

```bash
cd ops/compose
cp ../env/prod.env.example .env      # fill with REAL secrets — never commit .env
docker compose -f docker-compose.prod.yml up -d --build

# verify on loopback BEFORE touching the proxy
curl -fsS http://127.0.0.1:8087/api/v1/health/   # API (API_HOST_PORT)
curl -fsS -I http://127.0.0.1:3002/              # web (WEB_HOST_PORT)
```

Then register the vhosts with the host Caddy (DNS must resolve to the box first):

```bash
sudo mkdir -p /var/log/caddy
# append ops/caddy/keja.hostcaddy.snippet to /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

Postgres and Redis stay internal (no host ports). Persistent state lives under
`/srv/keja` (pgdata, redisdata, backups). The `web` image is built on the box;
`api`/`worker`/`beat` pull the published GHCR image (`docker login ghcr.io` first
if the package is private).

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
