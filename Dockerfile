# Use EE or CE; pin to the version you want.
FROM docker.io/appsmith/appsmith-ee:v1.85
# FROM docker.io/appsmith/appsmith-ce:v1.85

USER root
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

# Ensure expected dirs exist even before the Render disk mounts
RUN mkdir -p /appsmith-stacks /tmp/appsmith/www

# Replace Supervisor config (removes Caddy, adds nginx)
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Provide nginx config that binds to $PORT and proxies to the Appsmith server
COPY nginx.conf /etc/nginx/nginx.conf

# Keep the image’s original entrypoint (it initializes env/files and then runs supervisor)
# No CMD/ENTRYPOINT override needed.

