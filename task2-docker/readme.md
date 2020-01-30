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

MAINTAINER Kozulenko Volodymyr <fenixra73@gmail.com>     

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


## Now we try make Dockerfile v2.0
FROM centos:7     

MAINTAINER Kozulenko Volodymyr <fenixra73@gmail.com>     

RUN yum install deltarpm -y && \     
    yum update -y && \    
    yum -y install java-1.8.0-openjdk curl  wget epel-release && \      
    curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo |  tee /etc/yum.repos.d/jenkins.repo && \      
    rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \     
    rpm -v --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \     
    yum -y install jenkins     


EXPOSE 8080     

USER jenkins    

CMD ["java", "-jar", "/usr/lib/jenkins/jenkins.war"]  




## docker build -t jenkins:2.0 .
