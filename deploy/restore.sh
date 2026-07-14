#!/usr/bin/env sh
set -eu
if [ "$#" -ne 1 ]; then echo "Usage: $0 backups/file.dump" >&2; exit 2; fi
cd "$(dirname "$0")"
test -f "$1"
docker compose exec -T postgres pg_restore -U frostfarmer -d frostfarmer --clean --if-exists < "$1"
