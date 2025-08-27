FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori sementara agar tidak butuh root
RUN mkdir -p /tmp/nginx/logs /tmp/nginx/client-body /tmp/nginx/proxy \
    /tmp/nginx/run /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi

# Copy website
COPY app /app

# Konfigurasi nginx
RUN echo " \
error_log /tmp/nginx/logs/error.log; \
pid /tmp/nginx/run/nginx.pid; \
\
events { \
    worker_connections 1024; \
} \
\
http { \
    include /etc/nginx/mime.types; \
    default_type application/octet-stream; \
    sendfile on; \
    keepalive_timeout 65; \
\
    proxy_temp_path /tmp/nginx/proxy; \
    client_body_temp_path /tmp/nginx/client-body; \
    fastcgi_temp_path /tmp/nginx/fastcgi; \
    uwsgi_temp_path /tmp/nginx/uwsgi; \
    scgi_temp_path /tmp/nginx/scgi; \
\
    server { \
        listen 7860; \
        root /app; \
        index index.html; \
\
        access_log /tmp/nginx/logs/access.log; \
\
        location / { \
            try_files \$uri \$uri/ =404; \
        } \
    } \
} \
" > /etc/nginx/nginx.conf

# Hugging Face pakai port 7860
EXPOSE 7860

# Jalankan non-root user
USER 1000

CMD ["nginx", "-g", "daemon off;"]
