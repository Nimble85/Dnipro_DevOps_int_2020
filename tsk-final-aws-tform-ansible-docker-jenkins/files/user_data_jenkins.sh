#!/bin/bash
apt update
apt install -y awscli openjdk-8-jdk  openjdk-8-jre-headless
apt-get install -y  mc htop
apt-get install -y git
mkdir -p /home/ubuntu/jenkins_slave
chown -R ubuntu:ubuntu /home/ubuntu/ 
