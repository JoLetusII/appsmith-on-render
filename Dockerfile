FROM docker.io/appsmith/appsmith-ee:v1.85
# Or use CE edition:
# FROM docker.io/appsmith/appsmith-ce:v1.85

USER root

# Install nginx
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y nginx \
 && rm -rf /var/lib/apt/lists/*

# Ensure dirs exist before Render mounts the disk
RUN mkdir -p /appsmith-stacks /tmp/appsmith/www

# Replace Supervisor + nginx configs
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

# ---- Neutralize Caddy so entrypoint.sh doesn't crash ----
RUN if [ -x /opt/caddy/caddy ]; then \
      mv /opt/caddy/caddy /opt/caddy/caddy.real && \
      printf '#!/bin/sh\n# disabled on Render\nexit 0\n' > /opt/caddy/caddy && \
      chmod +x /opt/caddy/caddy; \
    fi
