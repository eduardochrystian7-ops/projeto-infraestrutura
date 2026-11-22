server {
    listen 80;
    server_name _;
    return 301 https://$host:__HTTPS_PORT__$request_uri;
}
server {
    listen 443 ssl;
    server_name servico.lab;
    ssl_certificate /etc/ssl/certs/servico.crt;
    ssl_certificate_key /etc/ssl/private/servico.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    root /var/www/html;
    index index.html;
    location /api/ {
        proxy_pass http://__APP_IP__:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}

