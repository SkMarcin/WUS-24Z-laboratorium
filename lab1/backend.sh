#!/bin/bash

backend_port=$1
db_ip=$2
db_port=$3
folder_path=$4

cd /root
mkdir $folder_path
cd $folder_path
sudo apt update
sudo apt upgrade -y

# sudo apt install -y default-jre
sudo apt install -y openjdk-17-jdk
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc
echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
sed -i "s/localhost/$db_ip/g" src/main/resources/application-mysql.properties
sed -i "s/3306/$db_port/g" src/main/resources/application-mysql.properties
sed -i "s/9966/$backend_port/g" src/main/resources/application.properties
sed -i "s/active=hsqldb/active=mysql/g" src/main/resources/application.properties
./mvnw spring-boot:run &
