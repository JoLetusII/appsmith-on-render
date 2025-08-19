#!/usr/bin/env bash
set -euo pipefail

echo "[start] Preparing nginx config..."
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "[start] Launching supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

