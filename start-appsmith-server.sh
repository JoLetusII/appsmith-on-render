#!/usr/bin/env bash
set -euo pipefail

echo "[server] locating entrypoint..."
if [[ -x /opt/appsmith/scripts/start-server.sh ]]; then
  echo "[server] using scripts/start-server.sh"
  exec /opt/appsmith/scripts/start-server.sh
elif [[ -f /opt/appsmith/backend/server.jar ]]; then
  echo "[server] using backend/server.jar"
  exec java -XX:+UseZGC -Dserver.port=8080 -jar /opt/appsmith/backend/server.jar
elif [[ -f /opt/appsmith/server.jar ]]; then
  echo "[server] using server.jar"
  exec java -XX:+UseZGC -Dserver.port=8080 -jar /opt/appsmith/server.jar
else
  echo "[server] ERROR: cannot find server jar or start script. Layout changed."
  ls -R /opt/appsmith || true
  exit 1
fi
