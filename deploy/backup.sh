#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
mkdir -p backups
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
docker compose exec -T postgres pg_dump -U frostfarmer -d frostfarmer -Fc > "backups/frostfarmer-$stamp.dump"
find backups -type f -name 'frostfarmer-*.dump' -mtime +14 -delete
echo "backups/frostfarmer-$stamp.dump"
