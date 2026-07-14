#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
test -f .env || { echo 'Missing deploy/.env' >&2; exit 2; }
grep -q 'replace-with-' .env && { echo 'Replace placeholder secrets in .env' >&2; exit 2; }
mkdir -p plugins backups
chmod 755 plugins
chmod 700 backups
docker compose config --quiet
old_image="$(docker compose images -q app 2>/dev/null || true)"
if docker compose ps --status running --services 2>/dev/null | grep -q '^postgres$'; then ./backup.sh; fi
docker compose pull
docker compose up -d --remove-orphans
attempt=0
until docker compose exec -T app curl --fail --silent http://127.0.0.1:8080/health/ready >/dev/null; do
  attempt=$((attempt+1));
  if [ "$attempt" -ge 30 ]; then
    docker compose logs --tail=100 app
    if [ -n "$old_image" ]; then echo 'Health check failed; rolling back application image.'; APP_IMAGE="$old_image" docker compose up -d app; fi
    exit 1
  fi
  sleep 2
done
docker image prune -f
docker compose ps
