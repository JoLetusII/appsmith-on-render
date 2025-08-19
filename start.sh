#!/bin/bash
set -euo pipefail

# External URL for redirects behind Render's proxy
if [ -n "${RENDER_EXTERNAL_URL:-}" ]; then
  export APPSMITH_SERVER_URL="$RENDER_EXTERNAL_URL"
fi

# Keep the Java server on 8080 (Caddy proxies to this)
export SERVER_PORT=8080

# JVM tuning for small instances
export JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

# --- Embedded Postgres safety sweep ---
# Ensure data dir exists
mkdir -p /appsmith-stacks/data/postgres/main || true
# Remove stale lock if present (fixes "no response" wait loop)
rm -f /appsmith-stacks/data/postgres/main/postmaster.pid || true
# Ensure socket directory exists (entrypoint checks /var/run/postgresql)
mkdir -p /var/run/postgresql || true
chown -R postgres:postgres /var/run/postgresql || true

# Encourage the embedded DB path (harmless if already default)
export APPSMITH_ENABLE_EMBEDDED_DB=true

# Hand off to Appsmith's entrypoint (Supervisor starts Postgres/Redis/Server)
exec /opt/appsmith/entrypoint.sh

