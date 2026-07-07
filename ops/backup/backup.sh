#!/usr/bin/env bash
# Keja backup (Phase 7): pg_dump the PostGIS db + optionally mirror object
# storage, into the /srv backup structure. Idempotent, safe to run from cron.
#
#   ops/backup/backup.sh
#
# Env (see ops/env/prod.env.example):
#   BACKUP_DIR             where dumps land          (default /srv/keja/backups)
#   BACKUP_RETENTION_DAYS  prune dumps older than N  (default 14)
#   DB_CONTAINER           compose db service/container name (default keja-prod-db-1)
#   PGUSER / PGDATABASE    postgres role / db        (default keja / keja)
#   MC_ALIAS / S3_BUCKET   optional: mirror object storage with `mc`
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/srv/keja/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
DB_CONTAINER="${DB_CONTAINER:-keja-prod-db-1}"
PGUSER="${PGUSER:-keja}"
PGDATABASE="${PGDATABASE:-keja}"

ts="$(date -u +%Y%m%dT%H%M%SZ)"
dump_dir="${BACKUP_DIR}/db"
mkdir -p "$dump_dir"
dump_file="${dump_dir}/keja-${ts}.dump"

echo "==> pg_dump ${PGDATABASE} -> ${dump_file}"
# Custom format (-Fc): compressed and restorable with pg_restore. Runs inside the
# db container so we never need a postgres client on the host.
docker exec "$DB_CONTAINER" \
	pg_dump -U "$PGUSER" -d "$PGDATABASE" -Fc \
	> "$dump_file"

# Guard against a silently-empty dump (disk full, wrong container, etc.).
if [ ! -s "$dump_file" ]; then
	echo "!! dump is empty — aborting" >&2
	rm -f "$dump_file"
	exit 1
fi
echo "    wrote $(du -h "$dump_file" | cut -f1)"

# Optional: mirror the media bucket to the same backup root.
if [ -n "${MC_ALIAS:-}" ] && [ -n "${S3_BUCKET:-}" ]; then
	echo "==> mirroring object storage ${MC_ALIAS}/${S3_BUCKET}"
	mc mirror --overwrite --remove "${MC_ALIAS}/${S3_BUCKET}" "${BACKUP_DIR}/media"
fi

echo "==> pruning db dumps older than ${RETENTION_DAYS} days"
find "$dump_dir" -name 'keja-*.dump' -type f -mtime "+${RETENTION_DAYS}" -print -delete

echo "==> backup complete: ${dump_file}"
