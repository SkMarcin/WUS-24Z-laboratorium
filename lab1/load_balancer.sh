#!/bin/bash

backend1_ip=$1
backend1_port=$2
backend2_ip=$3
backend2_port=$4
load_balancer_port=$5

cd /root
sudo apt update
sudo apt upgrade -y

sudo apt install -y nginx

cat << EOF > /etc/nginx/sites-enabled/load_balancer

log_format custom_log '$remote_addr - [$time_local] '
                          '"$request" '
                          'received_ip="$server_addr" '
                          'received_port="$server_port" '
                          'forwarded_ip="$upstream_addr" '
                          'status=$status '
                          'bytes_sent=$body_bytes_sent '
                          'response_time=$upstream_response_time';

access_log  /var/log/nginx/access.log custom_log;
error_log  /var/log/nginx/error_log;

upstream backend {
    server $backend1_ip:$backend1_port;
    server $backend2_ip:$backend2_port;
}

server {
    listen $load_balancer_port;

    location / {
        proxy_pass http://backend;
        include proxy_params;
    }
}

EOF

sudo nginx -s reload
