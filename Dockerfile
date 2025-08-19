# Pin the Appsmith version you want (example: v1.85). Avoid :latest in prod.
FROM docker.io/appsmith/appsmith-ee:v1.85

# Stop Supervisor from starting Caddy inside the container
RUN if [ -f /etc/supervisor/conf.d/caddy.conf ]; then \
      sed -i 's/^[[:space:]]*command=.*/command=\/bin\/true/' /etc/supervisor/conf.d/caddy.conf; \
    fi

# Copy our tiny start script and make it executable inside the image
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Start Appsmith via our script (which sets SERVER_PORT/APPSMITH_SERVER_URL)
ENTRYPOINT ["/usr/local/bin/start.sh"]
