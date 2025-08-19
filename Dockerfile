FROM ubuntu:24.04

# 1) Install runtime deps
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates curl gnupg supervisor nginx postgresql-common redis-server \
    && rm -rf /var/lib/apt/lists/*

# 2) Copy Appsmith bits from official image (editor, scripts, server)
#    You can also curl the release artifact if you prefer; using multi-stage keeps parity.
FROM docker.io/appsmith/appsmith-ee:v1.85 AS appsmith
# or appsmith-ce:v1.85

FROM ubuntu:24.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates curl gnupg supervisor nginx && rm -rf /var/lib/apt/lists/*

# Create stacks dir (Render disk will mount here)
RUN mkdir -p /appsmith-stacks /tmp/appsmith/www

# Bring over Appsmith runtime from the official image
COPY --from=appsmith /opt/appsmith /opt/appsmith
COPY --from=appsmith /opt/appsmith/editor /opt/appsmith/editor

# Nginx & Supervisor configs
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Environment compatibility
ENV APPSMITH_STANDALONE=1 \
    HOME=/root

# Expose nothing explicitly; Render injects $PORT and routes to it via nginx
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

