#!/bin/bash

# Ensure Render assigns the external URL correctly
if [ -n "$RENDER_EXTERNAL_URL" ]; then
  export APPSMITH_SERVER_URL="$RENDER_EXTERNAL_URL"
fi

# Force Appsmith to use the internal server port (Caddy will proxy)
export SERVER_PORT=8080

# Optional JVM tuning for low-memory plans
export JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

# Run the official Appsmith entrypoint
exec /opt/appsmith/entrypoint.sh

