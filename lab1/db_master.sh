#!/bin/bash
port=$1

cd /root
sudo apt update
sudo apt upgrade -y
sudo apt install -y mysql-server

echo "[mysqld]" | sudo tee -a /etc/mysql/my.cnf
echo "port=$port" | sudo tee -a /etc/mysql/my.cnf
echo "bind-address = 0.0.0.0" | sudo tee -a /etc/mysql/my.cnf
echo "server-id = 1" | sudo tee -a /etc/mysql/my.cnf
echo "log_bin = /var/log/mysql/mysql-bin.log" | sudo tee -a /etc/mysql/my.cnf

sudo service mysql restart

# Create the MySQL user and grant permissions

sudo mysql -e "CREATE USER IF NOT EXISTS 'petclinic'@'%' IDENTIFIED BY 'petclinic';"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS petclinic;"
sudo mysql -e "GRANT ALL PRIVILEGES ON petclinic.* TO 'petclinic'@'%' WITH GRANT OPTION;"

wget https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/refs/heads/master/src/main/resources/db/mysql/schema.sql
sed -i '1 i\USE petclinic;' ./schema.sql  # Add 'USE petclinic;' to the top of schema.sql
cat schema.sql | sudo mysql -f

wget https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/refs/heads/master/src/main/resources/db/mysql/data.sql
sed -i '1 i\USE petclinic;' ./data.sql  # Add 'USE petclinic;' to the top of data.sql
cat data.sql | sudo mysql -f

sudo mysql -v -e "UNLOCK TABLES;"

sudo mysql -e "CREATE USER 'replica_petclinic'@'%' IDENTIFIED WITH mysql_native_password BY 'replica_petclinic';"
sudo mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replica_petclinic'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"
