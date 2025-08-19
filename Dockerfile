# Appsmith EE v1.85 "fat" image (has server, rts, utils, entrypoint, etc.)
FROM appsmith/appsmith-ee:v1.85

# Install nginx + supervisor (no systemd) and envsubst for templating
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      nginx supervisor gettext-base \
 && rm -rf /var/lib/apt/lists/*

# ----- Disable Caddy cleanly (Render + Caddy can be prickly) -----
# Replace /opt/caddy/caddy with a harmless shim so the entrypoint never tries CAPs
RUN set -e; \
  if [ -x /opt/caddy/caddy ]; then \
    mv /opt/caddy/caddy /opt/caddy/caddy.real || true; \
    printf '%s\n' \
      '#!/usr/bin/env sh' \
      'echo "[shim] Caddy disabled"; exit 0' > /opt/caddy/caddy; \
    chmod +x /opt/caddy/caddy; \
  fi

# Nginx config template and Supervisor config
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Startup wrapper: renders nginx.conf from template and starts supervisord
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Make sure the directory nginx serves exists for the loading screen
RUN mkdir -p /tmp/appsmith/www

# EXPOSE is ignored by Render, but good documentation
EXPOSE 10000

# IMPORTANT on Render: the platform injects $PORT (typically 10000).
# We render nginx.conf to listen on that exact port at runtime.
CMD ["/usr/local/bin/start.sh"]

