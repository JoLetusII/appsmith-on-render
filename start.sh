#!/usr/bin/env bash
set -euo pipefail

echo "[start] Rendering nginx.conf with PORT=${PORT:-10000}"
envsubst '${PORT}' </etc/nginx/nginx.conf.template >/etc/nginx/nginx.conf
nginx -t

echo "[start] Launching supervisord with explicit config..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf


