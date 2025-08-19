#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-10000}"

# Render nginx.conf from template and validate it
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
echo "==> Using PORT=$PORT"
if ! nginx -t; then
  echo "NGINX CONFIG ERROR:"
  cat /etc/nginx/nginx.conf || true
  exit 1
fi

# show versions for quick diag
nginx -v || true
supervisord -v || true

# Start supervisord in the foreground
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
