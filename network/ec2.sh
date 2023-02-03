#!/bin/bash
sudo apt update -y
sudo apt install nginx -y 
echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${aws_alb.private-alb.dns_name}; \n  } \n}' > default
sudo mv default /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
sudo apt install curl -y