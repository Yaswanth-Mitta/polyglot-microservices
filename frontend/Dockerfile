FROM nginx:stable-alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy frontend build output
COPY index.html /usr/share/nginx/html/

# If you have JS/CSS assets, copy the whole folder:
# COPY dist/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

