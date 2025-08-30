FROM nginx:stable-alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy frontend static files
COPY index.html /usr/share/nginx/html/

EXPOSE 80

# Single ENTRYPOINT
ENTRYPOINT ["nginx", "-g", "daemon off;"]

