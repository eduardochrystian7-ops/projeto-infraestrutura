server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;
    location /api/ {
        proxy_pass http://__APP_IP__:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

