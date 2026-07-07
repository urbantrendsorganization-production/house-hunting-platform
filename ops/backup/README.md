# Backups (Phase 7)

`pg_dump` of the PostGIS database (+ optional object-storage mirror) into the
`/srv/keja/backups` structure on the Hetzner box.

## Take a backup

```bash
ops/backup/backup.sh
```

Writes `keja-<UTC-timestamp>.dump` (pg custom format) under `$BACKUP_DIR/db` and
prunes dumps older than `$BACKUP_RETENTION_DAYS`. Set `MC_ALIAS`/`S3_BUCKET` to
also mirror the media bucket.

## Restore (and rehearse regularly)

```bash
ops/backup/restore.sh /srv/keja/backups/db/keja-<timestamp>.dump
```

Drops, recreates and restores the database, then prints the PostGIS version and
building count as a smoke check. Pass `FORCE=1` to skip the confirmation prompt
in automated rehearsals.

> **An untested backup is not a backup.** Rehearse a restore into a scratch db
> at least monthly — this satisfies the Phase 7 gate.

## Schedule (cron on the host)

```cron
# Nightly at 02:15 Africa/Nairobi
15 2 * * * cd /srv/keja/app && ops/backup/backup.sh >> /srv/keja/backups/backup.log 2>&1
```

## Environment

| Var | Default | Meaning |
|---|---|---|
| `BACKUP_DIR` | `/srv/keja/backups` | backup root |
| `BACKUP_RETENTION_DAYS` | `14` | prune dumps older than this |
| `DB_CONTAINER` | `keja-prod-db-1` | compose db container |
| `PGUSER` / `PGDATABASE` | `keja` / `keja` | postgres role / db |
| `MC_ALIAS` / `S3_BUCKET` | — | optional media mirror via `mc` |
