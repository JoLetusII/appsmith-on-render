#!/usr/bin/env bash
set -euo pipefail

log() { printf '[server] %s\n' "$*"; }

# --- small TCP wait helper using /dev/tcp (no netcat needed) ---
wait_tcp() {
  local host="$1" port="$2" name="${3:-$host:$port}" tries="${4:-60}" sleep_s="${5:-1}"
  for ((i=1;i<=tries;i++)); do
    if exec 3<>"/dev/tcp/$host/$port" 2>/dev/null; then
      exec 3>&- 3<&-
      log "reachable: $name"
      return 0
    fi
    log "waiting for $name... ($i/$tries)"
    sleep "$sleep_s"
  done
  log "GAVE UP waiting for $name after $tries tries"
  return 1
}

log "java version:"; (java -version || true) 2>&1 | sed 's/^/[server] /'

# --- wait for embedded Mongo ---
wait_tcp 127.0.0.1 27017 mongo || true

# --- wait for external Postgres if APPSMITH_KEYCLOAK_DB_URL is set ---
if [[ -n "${APPSMITH_KEYCLOAK_DB_URL:-}" ]]; then
  # parse host:port crudely from URL: postgresql://user:pass@host:port/db
  pg_url="${APPSMITH_KEYCLOAK_DB_URL#*@}"          # host:port/db...
  pg_host="${pg_url%%[:/]*}"
  pg_rest="${pg_url#"$pg_host"}"
  pg_port="${pg_rest#:}"; pg_port="${pg_port%%/*}"
  [[ "$pg_port" =~ ^[0-9]+$ ]] || pg_port=5432
  wait_tcp "$pg_host" "$pg_port" "postgres($pg_host:$pg_port)" || true
fi

log "locating entrypoint..."
if [[ -x /opt/appsmith/scripts/start-server.sh ]]; then
  log "using scripts/start-server.sh"
  exec /opt/appsmith/scripts/start-server.sh
fi

# try the common jar locations
jar=""
for p in \
  /opt/appsmith/backend/server.jar \
  /opt/appsmith/server.jar \
  /opt/appsmith/app/server.jar \
  /opt/appsmith/*/server.jar
do
  [[ -f "$p" ]] && { jar="$p"; break; }
done

if [[ -n "$jar" ]]; then
  log "using jar: $jar"
  exec java -XX:+UseZGC -Dserver.port=8080 -jar "$jar"
fi

log "ERROR: cannot find server jar or start script. Layout changed."
ls -al /opt/appsmith || true
ls -al /opt/appsmith/backend 2>/dev/null || true
exit 1

