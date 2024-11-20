#!/bin/bash

backend_ip=$1
backend_port=$2
frontend_port=$3

cd /root
sudo apt update
sudo apt upgrade -y
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 16
git clone https://github.com/spring-petclinic/spring-petclinic-angular
cd spring-petclinic-angular
sed -i "s/localhost/$backend_ip/g" src/environments/environment.prod.ts src/environments/environment.ts
sed -i "s/9966/$backend_port/g" src/environments/environment.prod.ts src/environments/environment.ts
npm install
npm install -g angular-http-server
npm run build -- --configuration production
nohup npx angular-http-server --path ./dist -p $frontend_port > angular.out 2> angular.err &
