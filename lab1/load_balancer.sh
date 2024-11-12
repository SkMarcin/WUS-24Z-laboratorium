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
http {
   log_format upstreamlog '$server_name to: $upstream_addr {$request} '
   'upstream_response_time $upstream_response_time'
   ' request_time $request_time';
}

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
