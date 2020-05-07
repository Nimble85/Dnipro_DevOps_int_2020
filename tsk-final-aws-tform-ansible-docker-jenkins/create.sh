#!/bin/bash
cd dev
terraform apply -input=false -auto-approve
cd ..
cd prod
terraform apply -input=false -auto-approve
cd ..
ip_jenk=`<dev/ip_jenkins`
cp -f dev/config.xml  dev/ansible/roles/docker/files/db/config.xml
cp -f dev/config.xml.test  dev/ansible/roles/docker/files/slave_test/config.xml.test
cp -f prod/config.xml  dev/ansible/roles/docker/files/db_prod/config.xml

cd dev
sleep 60
ansible-playbook -vvv --private-key ~/.ssh/jenkins.pem  -i aws_hosts_jenkins ansible/bootstrap_jenkins.yml --extra-vars "ip_jenkins=$ip_jenk" --vault-password-file pass.txt
 
