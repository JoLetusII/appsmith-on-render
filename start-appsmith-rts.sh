#!/usr/bin/env bash
set -euo pipefail
echo "[rts] node version:"; node -v || true
echo "[rts] locating entrypoint..."
if [[ -x /opt/appsmith/scripts/start-rts.sh ]]; then
  echo "[rts] using scripts/start-rts.sh"
  exec /opt/appsmith/scripts/start-rts.sh
elif [[ -f /opt/appsmith/rts/server/dist/server.js ]]; then
  echo "[rts] using rts/server/dist/server.js"
  exec node /opt/appsmith/rts/server/dist/server.js
elif [[ -f /opt/appsmith/rts/dist/server.js ]]; then
  echo "[rts] using rts/dist/server.js"
  exec node /opt/appsmith/rts/dist/server.js
else
  echo "[rts] ERROR: cannot find RTS entrypoint. Layout changed."
  ls -R /opt/appsmith/rts || true
  exit 1
fi
