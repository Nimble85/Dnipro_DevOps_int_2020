#!/bin/bash

cp  ${REF}/plugins/*.jpi ${JENKINS_HOME}/plugins \
   && echo "List of plugins in folder ${JENKINS_HOME}/plugins" && ls -la ${JENKINS_HOME}/plugins

/usr/sbin/nginx 

java -jar -Djenkins.install.runSetupWizard=false /usr/share/jenkins/jenkins.war 
