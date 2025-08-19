#!/usr/bin/env bash
set -euo pipefail

log(){ printf '[mongo] %s\n' "$*"; }

DATA_DIR="/appsmith-stacks/data/mongodb"
KEY_TMP="/tmp/appsmith/mongodb-key"
KEY_DATA="$DATA_DIR/key"

mkdir -p "$DATA_DIR"

# Pick the key the entrypoint copies, fall back to the data dir key
if [[ -f "$KEY_TMP" ]]; then
  KEY="$KEY_TMP"
elif [[ -f "$KEY_DATA" ]]; then
  KEY="$KEY_DATA"
else
  log "ERROR: no key file at $KEY_TMP or $KEY_DATA"
  ls -al /tmp/appsmith || true
  ls -al "$DATA_DIR" || true
  exit 1
fi

# mongod requires 600 on the key file
chmod 600 "$KEY" || true

# Start mongod bound to loopback, with rs0 (what Appsmith uses)
exec mongod \
  --bind_ip 127.0.0.1 \
  --port 27017 \
  --dbpath "$DATA_DIR" \
  --replSet rs0 \
  --keyFile "$KEY" \
  --wiredTigerCacheSizeGB 1

