FROM docker.io/appsmith/appsmith-ce:latest

# Tools to manage Linux file capabilities/xattrs (ignore if unavailable)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libcap2-bin attr && \
    rm -rf /var/lib/apt/lists/*

# Wrap the Caddy binary:
# - move the real binary
# - strip capabilities so exec won't EPERM on Render
# - install a wrapper that edits the Caddyfile to use $PORT and disables tls
RUN set -e; \
    if [ -x /opt/caddy/caddy ]; then \
      mv /opt/caddy/caddy /opt/caddy/caddy.real; \
      (setcap -r /opt/caddy/caddy.real 2>/dev/null || true); \
      (setfattr -x security.capability /opt/caddy/caddy.real 2>/dev/null || true); \
      printf '%s\n' \
        '#!/bin/sh' \
        'set -e' \
        'if [ -n "$PORT" ] && [ -f /etc/caddy/Caddyfile ]; then' \
        '  sed -i "s/:80/:$PORT/g; s/:443/:$PORT/g" /etc/caddy/Caddyfile || true' \
        '  sed -i "/^[[:space:]]*tls\\b/d" /etc/caddy/Caddyfile 2>/dev/null || true' \
        'fi' \
        'exec /opt/caddy/caddy.real "$@"' \
        > /opt/caddy/caddy && chmod +x /opt/caddy/caddy; \
    fi

# (Optional) keep your helper start script; it just sets SERVER_PORT & URL then hands off
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]

