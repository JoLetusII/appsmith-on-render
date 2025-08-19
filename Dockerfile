FROM docker.io/appsmith/appsmith-ee:v1.85
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y nginx \
 && rm -rf /var/lib/apt/lists/*

# Ensure dirs exist before Render mounts the disk
RUN mkdir -p /appsmith-stacks /tmp/appsmith/www

# Replace Supervisor config (removes caddy, adds nginx)
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

# ---- Neutralize Caddy so entrypoint.sh doesn't crash ----
# Keep the original around (just in case), but make /opt/caddy/caddy a harmless no-op.
RUN if [ -x /opt/caddy/caddy ]; then \
      mv /opt/caddy/caddy /opt/caddy/caddy.real && \
      printf '#!/bin/sh\n# disabled on Render\nexit 0\n' > /opt/caddy/caddy && \
      chmod +x /opt/caddy/caddy; \
    fi

# Keep upstream entrypoint (it does important first-run setup) -> will exec supervisord with our config.
