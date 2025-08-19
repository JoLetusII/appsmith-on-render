#!/bin/sh
set -e

# Make Appsmith listen on Render's assigned port
export SERVER_PORT="${PORT:-8080}"

# Advertise the correct external URL for redirects/OAuth behind Render’s proxy
[ -n "$RENDER_EXTERNAL_URL" ] && export APPSMITH_SERVER_URL="$RENDER_EXTERNAL_URL"

# Start Appsmith's normal supervisor-driven entrypoint (without Caddy)
exec /opt/appsmith/entrypoint.sh

