FROM appsmith/appsmith-ee:v1.85
# or: FROM appsmith/appsmith-ce:v1.85

USER root
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      nginx supervisor gettext-base \
 && rm -rf /var/lib/apt/lists/*

# Disable Caddy so upstream entrypoint never tries to run it with caps
RUN if [ -x /opt/caddy/caddy ]; then \
      mv /opt/caddy/caddy /opt/caddy/caddy.real || true; \
      printf '#!/usr/bin/env sh\necho "[shim] Caddy disabled"\nexit 0\n' > /opt/caddy/caddy; \
      chmod +x /opt/caddy/caddy; \
    fi

# Ensure dirs exist
RUN mkdir -p /appsmith-stacks /tmp/appsmith/www

# Config & launch scripts
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY start.sh /usr/local/bin/start.sh
COPY start-appsmith-server.sh /usr/local/bin/start-appsmith-server.sh
COPY start-appsmith-rts.sh    /usr/local/bin/start-appsmith-rts.sh
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/start-appsmith-*.sh

# Render/Railway inject $PORT at runtime; start.sh templates nginx then launches supervisord
CMD ["/usr/local/bin/start.sh"]



