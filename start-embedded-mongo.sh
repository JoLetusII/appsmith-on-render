#!/usr/bin/env bash
set -euo pipefail

log(){ printf '[mongo] %s\n' "$*"; }

# Paths used by the Appsmith image during init
DATA_DIR="/appsmith-stacks/data/mongodb"
KEY_IN_DATA="$DATA_DIR/key"
KEY_IN_TMP="/tmp/appsmith/mongodb-key"

# Ensure data dir exists
mkdir -p "$DATA_DIR"

# Prefer the key that Appsmith copies into /tmp during init
if [[ -f "$KEY_IN_TMP" ]]; then
  log "using key: $KEY_IN_TMP"
  chmod 600 "$KEY_IN_TMP" || true
  KEY="$KEY_IN_TMP"
elif [[ -f "$KEY_IN_DATA" ]]; then
  log "using key: $KEY_IN_DATA"
  chmod 600 "$KEY_IN_DATA" || true
  KEY="$KEY_IN_DATA"
else
  log "ERROR: no MongoDB key file found at $KEY_IN_TMP or $KEY_IN_DATA"
  ls -al /tmp/appsmith || true
  ls -al "$DATA_DIR" || true
  exit 1
fi

# Start mongod with replica set (Appsmith expects rs0)
exec mongod \
  --bind_ip 127.0.0.1 \
  --port 27017 \
  --dbpath "$DATA_DIR" \
  --replSet rs0 \
  --keyFile "$KEY" \
  --wiredTigerCacheSizeGB 1
