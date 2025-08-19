#!/usr/bin/env bash
set -euo pipefail

# Template nginx config with runtime $PORT
: "${PORT:=10000}"
echo "[start] Rendering nginx.conf with PORT=$PORT"
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Validate nginx before starting supervisord
nginx -t

echo "[start] Launching supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

