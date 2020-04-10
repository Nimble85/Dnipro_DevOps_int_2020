#!/bin/bash
sudo mkdir -p /var/www/html/
sudo aws s3 sync s3://fenixra-site/task10  /var/www/html/
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/

