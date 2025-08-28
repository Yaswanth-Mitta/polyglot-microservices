FROM nginx:stable-alpine

# copy frontend build output into nginx html folder
COPY . /usr/share/nginx/html

# expose nginx default port
EXPOSE 80

# replace placeholder with EC2_IP env var at container startup
CMD sh -c "sed -i 's|__BASE_IP_PLACEHOLDER__|${EC2_IP}|g' /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"

