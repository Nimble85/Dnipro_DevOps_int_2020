#!/bin/bash
sudo yum update -y
sudo yum install -y  mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
#sudo mysql -u root 
sudo aws s3 cp s3://fenixra-site/db/dbpdo.sql  ~/dbpdo.sql
sudo mysql -u root -e "CREATE DATABASE dbpdo;"
mysql -u root -e "USE dbpdo;"
mysql -u root -e "CREATE USER 'dbpdo'@'%' IDENTIFIED BY 'dbpdo';"
mysql -u root -e "CREATE USER 'dbpdo'@'localhost' IDENTIFIED BY 'dbpdo';"
mysql -u root -e "CREATE USER 'dbpdo'@'127.0.0.1' IDENTIFIED BY 'dbpdo';"
mysql -u root -e "GRANT ALL PRIVILEGES ON * . * TO 'dbpdo'@'%';"
mysql -u root -e "GRANT ALL PRIVILEGES ON * . * TO 'dbpdo'@'localgost';"
mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root  dbpdo< ~/dbpdo.sql;

#sudo aws s3 sync s3://fenixra-site  /var/www/html/
