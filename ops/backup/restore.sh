#!/usr/bin/env bash
# Keja restore (Phase 7): restore a pg_dump into the running db. Rehearse this
# regularly — an untested backup is not a backup.
#
#   ops/backup/restore.sh /srv/keja/backups/db/keja-20260707T101500Z.dump
#
# Env:
#   DB_CONTAINER   compose db container      (default keja-prod-db-1)
#   PGUSER         postgres role             (default keja)
#   PGDATABASE     target database           (default keja)
#   FORCE=1        skip the confirmation prompt (for automated rehearsals)
set -euo pipefail

dump_file="${1:-}"
if [ -z "$dump_file" ] || [ ! -f "$dump_file" ]; then
	echo "usage: $0 <path-to.dump>" >&2
	exit 1
fi

DB_CONTAINER="${DB_CONTAINER:-keja-prod-db-1}"
PGUSER="${PGUSER:-keja}"
PGDATABASE="${PGDATABASE:-keja}"

if [ "${FORCE:-0}" != "1" ]; then
	echo "This will DROP and recreate '${PGDATABASE}' in ${DB_CONTAINER}."
	read -r -p "Type the database name to confirm: " confirm
	[ "$confirm" = "$PGDATABASE" ] || { echo "aborted"; exit 1; }
fi

echo "==> terminating existing connections to ${PGDATABASE}"
docker exec -i "$DB_CONTAINER" psql -U "$PGUSER" -d postgres -v ON_ERROR_STOP=1 <<SQL
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '${PGDATABASE}' AND pid <> pg_backend_pid();
DROP DATABASE IF EXISTS ${PGDATABASE};
CREATE DATABASE ${PGDATABASE} OWNER ${PGUSER};
SQL

echo "==> restoring ${dump_file}"
# pg_restore recreates PostGIS objects captured in the dump; --no-owner keeps it
# portable across roles.
docker exec -i "$DB_CONTAINER" \
	pg_restore -U "$PGUSER" -d "$PGDATABASE" --no-owner --clean --if-exists \
	< "$dump_file"

echo "==> restore complete. Verifying PostGIS + row counts..."
docker exec -i "$DB_CONTAINER" psql -U "$PGUSER" -d "$PGDATABASE" -c \
	"SELECT PostGIS_Lib_Version() AS postgis, (SELECT count(*) FROM core_building) AS buildings;"
