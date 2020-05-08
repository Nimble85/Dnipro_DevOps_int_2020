#!/bin/bash
cd dev
terraform apply -input=false -auto-approve                       # deploy Dev environment                   
cd ..
cd prod
terraform apply -input=false -auto-approve                       # deploy Prod environment
cd ..
ip_jenk=`<dev/ip_jenkins`                                                              # var for webhoock github
cp -f dev/config.xml  dev/ansible/roles/docker/files/db/config.xml                     # configuring slave node Jenkins for db_dev
cp -f dev/config.xml.test  dev/ansible/roles/docker/files/slave_test/config.xml.test   # configuring slave node  Jenkins for test 
cp -f prod/config.xml  dev/ansible/roles/docker/files/db_prod/config.xml               # configuring slave node Jenkins for db_prod

cd dev
sleep 60
# configuring instance jenkins
ansible-playbook -vvv --private-key ~/.ssh/jenkins.pem  -i aws_hosts_jenkins ansible/bootstrap_jenkins.yml --extra-vars "ip_jenkins=$ip_jenk" --vault-password-file pass.txt
 
