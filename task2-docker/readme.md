# Docker
### tasks
1.	Создать Dockerfile на основе чистого образа Ubuntu из https://hub.docker.com/
2.	Установить Jenkins внутрь контейнера
3.	Предустановить нежные плагины
4.	Сделать доступное описание в файле README.MD
5.	Проект залить на https://github.com/


## Solution
### Dockerfile v1.0
FROM centos:7     

LABEL Kozulenko Volodymyr <fenixra73@gmail.com>     

RUN yum install deltarpm -y && \     
    yum update -y && \    
    yum -y install java-1.8.0-openjdk curl  wget epel-release && \      
    curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo |  tee /etc/yum.repos.d/jenkins.repo && \      
    rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \     
    rpm -v --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \     
    yum -y install jenkins     


EXPOSE 8080     
.
USER jenkins    

CMD ["java", "-jar", "/usr/lib/jenkins/jenkins.war"]     

### docker build -t jenkins .


### docker run -it  -p 8080:8080 jenkins
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic0.png  )

* After this we have a result
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic1.png  )


## Now I try make Dockerfile v3.0 (it was litle bit complicated, only version 3.0 was succeful) 
FROM centos:7       
RUN yum update -y && yum install -y epel-release && yum install -y git curl dpkg java java-devel unzip which && curl -s \     
https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && yum install -y git-lfs && yum clean all       
ENV JAVA_HOME /etc/alternatives/jre_openjdk     
ARG user=jenkins      
ARG group=jenkins      
ARG uid=1000     
ARG gid=1000      
ARG http_port=8080      
ARG JENKINS_HOME=/var/jenkins_home     
ARG REF=/usr/share/jenkins/ref      

ENV JENKINS_HOME $JENKINS_HOME       
ENV REF $REF      

#Jenkins is run with user `jenkins`, uid = 1000     
#If you bind mount a volume from the host or a data container,     
#ensure you use the same uid      
RUN mkdir -p $JENKINS_HOME \       
  && chown ${uid}:${gid} $JENKINS_HOME \       
  && groupadd -g ${gid} ${group} \       
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}       

#Jenkins home directory is a volume, so configuration and build history       
#can be persisted and survive image upgrades       
VOLUME $JENKINS_HOME       

#$REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want      
#to set on a fresh new installation. Use it to bundle additional plugins       
#or config file with your custom jenkins Docker image.      
RUN mkdir -p ${REF}/init.groovy.d       

#jenkins version being bundled in this docker image      
ARG JENKINS_VERSION       
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.99}      
#ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"       

#Can be used to customize where jenkins.war get downloaded from      
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war      

#could use ADD but this one does not check Last-Modified header neither does it allow to control checksum       
#see https://github.com/docker/docker/issues/8331     
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war      
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false      
ENV JENKINS_UC https://updates.jenkins.io       
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental      
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals       
RUN chown -R ${user} "$JENKINS_HOME" "$REF"        

#for main web interface:)      
EXPOSE ${http_port}      

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log      

USER ${user}     

#copy scripts for autoinstall plwugins     
COPY jenkins-support /usr/local/bin/jenkins-support     
COPY install-plugins.sh /usr/local/bin/install-plugins.sh      
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt      
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt      

#copy groovy script for disable setup wizard and create admin account      
COPY basic-security.groovy $JENKINS_HOME/init.groovy.d/basic-security.groovy      
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]       

# For create account i use script basic-security.groovy
#!groovy   
import jenkins.model.*    
import hudson.util.*;    
import jenkins.install.*;   
import hudson.security.*   

def instance = Jenkins.getInstance()    
def hudsonRealm = new HudsonPrivateSecurityRealm(false)   
hudsonRealm.createAccount("light","burulka")    
instance.setSecurityRealm(hudsonRealm)     
instance.save()    
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)    

# All Scripts for auto install plugins , such as install-plagin.sh jenkins-support, was taken from official docker site https://github.com/jenkinsci/docker


## docker build -t jenkins:3.0 .
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic2.png  )

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic5.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic6.png  )

## docker run -it -p 8080:8080 jenkins:3.0
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic3.png  )


# Result After runing the container 

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task2-docker/screenshot/pic4.png  )