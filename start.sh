#!/usr/bin/env bash
set -euo pipefail

# Default PORT for local runs; Render sets $PORT for you.
PORT="${PORT:-10000}"

# Render nginx.conf from template with the right $PORT
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Show versions for quick debugging
echo "==> Using PORT=$PORT"
nginx -v || true
supervisord -v || true

# Start supervisord in the foreground
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
