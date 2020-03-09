#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y nginx1
sudo aws s3 sync s3://fenixra-site /usr/share/nginx/html/
sudo chown nginx:nginx -R /usr/share/nginx/html/
sudo systemctl enable nginx
sudo systemctl start nginx


