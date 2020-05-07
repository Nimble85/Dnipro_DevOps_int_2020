#!/bin/bash
apt update
apt install -y awscli openjdk-8-jdk  openjdk-8-jre-headless
apt-get install -y maven mc htop
apt-get install -y  libxml-writer-perl libxml-sax-base-perl libxml-perl libxml-filter-saxt-perl libtext-glob-perl
apt-get install -y postgresql
apt-get install -y git
PSQL_USER=ubuntu
PSQL_PWD=ubuntu
echo "host      all     all     0.0.0.0/0       password" >> /etc/postgresql/10/main/pg_hba.conf
echo "export PSQL_USER=$PSQL_USER;" >> ~/.bashrc
echo "export PSQL_PWD=$PSQL_PWD;" >> ~/.bashrc
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/10/main/postgresql.conf
su postgres -c "psql -c \"CREATE ROLE $PSQL_USER SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '$PSQL_PWD'\";"
systemctl restart postgresql
mkdir -p /home/ubuntu/jenkins_slave
chown -R ubuntu:ubuntu /home/ubuntu/

