#!/usr/bin/env bash
set -euo pipefail

log() { printf '[rts] %s\n' "$*"; }

if [[ "${APPSMITH_RTS_ENABLED:-true}" != "true" ]]; then
  log "disabled via APPSMITH_RTS_ENABLED=false"
  exit 0
fi

log "node version:"; (node -v || true) 2>&1 | sed 's/^/[rts] /'

log "locating entrypoint..."
if [[ -x /opt/appsmith/scripts/start-rts.sh ]]; then
  log "using scripts/start-rts.sh"
  exec /opt/appsmith/scripts/start-rts.sh
fi

for p in \
  /opt/appsmith/rts/server/dist/server.js \
  /opt/appsmith/rts/dist/server.js \
  /opt/appsmith/*/rts/dist/server.js
do
  if [[ -f "$p" ]]; then
    log "using: $p"
    exec node "$p"
  fi
done

log "ERROR: cannot find RTS entrypoint. Layout changed."
ls -R /opt/appsmith/rts 2>/dev/null || true
exit 1
