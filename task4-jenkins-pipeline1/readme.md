# Jenkins pipeline 1
# Task:
```
1.	Сборка докер имеджа и пуш на свой аккаунт на докер хабе (https://hub.docker.com).        
Прикладываю описание имеджа, но можно использовать тот, что вы делали в ДЗ по докеру:          
Jenkins CI сервер на основе Ubuntu – стандартная инсталляция Jenkins + java+ Maven (для будущего актифактори).      
Создать пользователя jenkins с привелегиями управления сервером CI.  
Бонусное задание (nice to have😊): установить в этот же контейнер nginx и использовать 
его как прокси, т.е. стучаться на Jenkins server через nginx.
Протестировать  работу вашего Jenkins контейнера отдельным стейджем после сборки (в той же пайплайне). 
Т.е. curl/wget проверить соединение в райнтайме (или любой другой способ).
Любые ваши дополнения или улучшения приветствуются.
```
# Solution

* Dockerfile
```
FROM centos:7

RUN yum update -y && yum install -y epel-release && yum install -y git curl net-tools dpkg java java-devel unzip which &&  yum install -y maven  nginx && yum clean all
ENV JAVA_HOME /etc/alternatives/jre_openjdk


# enable docker & nginx
RUN systemctl enable nginx

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV REF $REF

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} 
  

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d


# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=http://updates.jenkins-ci.org/download/war/2.219/jenkins.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war 
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# config git user
RUN git config --global user.name "Volodymyr Kozulenko" && git config --global user.email fenixra73@gmail.com

# for main web interface:
EXPOSE 80

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log


RUN usermod -aG nginx jenkins
RUN usermod -aG root jenkins

RUN chmod -R 766 /var/log/nginx/

RUN chown -R ${user} "$JENKINS_HOME" "$REF"

COPY jenkins-support /usr/local/bin/jenkins-support
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY run.sh /usr/local/bin/run.sh

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup $REF/plugins from a support bundle
#COPY plugins.sh /usr/local/bin/plugins.sh

USER root
RUN chmod +x /usr/local/bin/*.sh

USER ${user}

ENTRYPOINT /usr/local/bin/run.sh

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#CMD ["java", "-jar", "-Djenkins.install.runSetupWizard=false", "/usr/share/jenkins/jenkins.war"]


# copy groovy scripd for create user and  disable initial setup
COPY basic-security.groovy $JENKINS_HOME/init.groovy.d/basic-security.groovy


# copy  nginx config
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
USER root
RUN chown nginx:nginx /etc/nginx/nginx.conf



#ENTRYPOINT /usr/sbin/nginx && java -jar -Djenkins.install.runSetupWizard=false /usr/share/jenkins/jenkins.war
ENTRYPOINT /usr/local/bin/run.sh

```

* first-pipeline.jenkins
```
#!groovy
// Run docker build
properties([disableConcurrentBuilds()])

pipeline {
    agent { 
        label 'master'
        }
    triggers { pollSCM('* * * * *') }
    options {
        buildDiscarder(logRotator(numToKeepStr: '2', artifactNumToKeepStr: '2'))
        timestamps()
    }
    stages {
        stage("docker build") {
            steps {
                echo "===============build image======================="
                dir ('task4-jenkins-pipeline1/docker') {
                    sh 'docker build --rm -t lightlook/cent-jenk-nginx:v8.0 .'
                }
             }
        }   
        stage("docker run") {
            steps {
                echo "===============docker run container======================="
                dir ('task4-jenkins-pipeline1/docker') {
                    sh 'mkdir -p /opt/jenkins_home/ && docker run --rm --name cent-jenk-nginx -d -p80:80 -v /opt/jenkins_home:/var/jenkins_home  lightlook/cent-jenk-nginx:v8.0 '
                }
             }    
        }
        stage("check running jenkins") {
            steps {
                echo "===============check running jenkins======================="
                sh 'sleep 80'
                sh 'curl http://localhost | grep -o "Welcome to Jenkins"'
             }    
        }
        stage("stop container") {
            steps {
                echo "===============stop container jenkins======================="
                sh 'docker stop cent-jenk-nginx'
             }    
        }
        stage("login to docker hub") {
            steps {
                echo " ============== login to docker hub =================="
                withCredentials([usernamePassword(credentialsId: 'dockerhub_lightlook', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'docker login -u "$USERNAME" -p "$PASSWORD"'
                }
            }
        }
        stage("docker push") {
            steps {
                echo " ============== start pushing image =================="
                sh   'docker push lightlook/cent-jenk-nginx:v8.0'
            }
         }
       }
}

```

## Log pipeline
```
Started by an SCM change
Started by user lightlook
Rebuilds build #64
Obtained task4-jenkins-pipeline1/jenkins/first-pipeline.jenkins from git https://github.com/fenixra73/Dnipro_DevOps_int_2020.git
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] properties
[Pipeline] node
Running on Jenkins in /var/lib/jenkins/workspace/1pipeline
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
No credentials specified
 > git rev-parse --is-inside-work-tree # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/fenixra73/Dnipro_DevOps_int_2020.git # timeout=10
Fetching upstream changes from https://github.com/fenixra73/Dnipro_DevOps_int_2020.git
 > git --version # timeout=10
 > git fetch --tags --progress https://github.com/fenixra73/Dnipro_DevOps_int_2020.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision e0a4155b27c1721a5d7b4d6b8981235689f16717 (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f e0a4155b27c1721a5d7b4d6b8981235689f16717 # timeout=10
Commit message: "fix"
 > git rev-list --no-walk b066f995b5de3904610b88b7f04da27a22fe4c49 # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] timestamps
[Pipeline] {
[Pipeline] stage
[Pipeline] { (docker build)
[Pipeline] echo
18:35:18  ===============build image=======================
[Pipeline] dir
18:35:18  Running in /var/lib/jenkins/workspace/1pipeline/task4-jenkins-pipeline1/docker
[Pipeline] {
[Pipeline] sh
18:35:18  + docker build --rm -t lightlook/cent-jenk-nginx:v8.0 .
18:35:18  Sending build context to Docker daemon  33.28kB

18:35:18  Step 1/46 : FROM centos:7
18:35:18   ---> 5e35e350aded
18:35:18  Step 2/46 : RUN yum update -y && yum install -y epel-release && yum install -y git curl net-tools dpkg java java-devel unzip which &&  yum install -y maven  nginx && yum clean all
18:35:18   ---> Using cache
18:35:18   ---> 7fdaae5dc52d
18:35:18  Step 3/46 : ENV JAVA_HOME /etc/alternatives/jre_openjdk
18:35:18   ---> Using cache
18:35:18   ---> 25d0213ce4f5
18:35:18  Step 4/46 : RUN systemctl enable nginx
18:35:18   ---> Using cache
18:35:18   ---> af42a7efe642
18:35:18  Step 5/46 : ARG user=jenkins
18:35:18   ---> Using cache
18:35:18   ---> 369b585a0f1c
18:35:18  Step 6/46 : ARG group=jenkins
18:35:18   ---> Using cache
18:35:18   ---> fb82c5a756d9
18:35:18  Step 7/46 : ARG uid=1000
18:35:18   ---> Using cache
18:35:18   ---> 32887ba4d98c
18:35:18  Step 8/46 : ARG gid=1000
18:35:18   ---> Using cache
18:35:18   ---> d93c89c891a0
18:35:18  Step 9/46 : ARG http_port=8080
18:35:18   ---> Using cache
18:35:18   ---> 79b3ceab948b
18:35:18  Step 10/46 : ARG JENKINS_HOME=/var/jenkins_home
18:35:18   ---> Using cache
18:35:18   ---> 242b39a17f34
18:35:18  Step 11/46 : ARG REF=/usr/share/jenkins/ref
18:35:18   ---> Using cache
18:35:18   ---> daca2141d349
18:35:18  Step 12/46 : ENV JENKINS_HOME $JENKINS_HOME
18:35:18   ---> Using cache
18:35:18   ---> 18ea74530f20
18:35:18  Step 13/46 : ENV REF $REF
18:35:18   ---> Using cache
18:35:18   ---> 6720bb4b5331
18:35:18  Step 14/46 : RUN mkdir -p $JENKINS_HOME   && chown ${uid}:${gid} $JENKINS_HOME   && groupadd -g ${gid} ${group}   && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
18:35:18   ---> Using cache
18:35:18   ---> a6bb25763a91
18:35:18  Step 15/46 : VOLUME $JENKINS_HOME
18:35:18   ---> Using cache
18:35:18   ---> 8ab12b0d1296
18:35:18  Step 16/46 : RUN mkdir -p ${REF}/init.groovy.d
18:35:18   ---> Using cache
18:35:18   ---> fb55c0f2b9c9
18:35:18  Step 17/46 : ARG JENKINS_VERSION
18:35:18   ---> Using cache
18:35:18   ---> 4bc44302a032
18:35:18  Step 18/46 : ENV JENKINS_VERSION ${JENKINS_VERSION:-2.99}
18:35:18   ---> Using cache
18:35:18   ---> 43771ecab14d
18:35:18  Step 19/46 : ARG JENKINS_URL=http://updates.jenkins-ci.org/download/war/2.219/jenkins.war
18:35:18   ---> Using cache
18:35:18   ---> f90e675c8ce0
18:35:18  Step 20/46 : RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war
18:35:18   ---> Using cache
18:35:18   ---> d00eac0d27d8
18:35:18  Step 21/46 : ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
18:35:18   ---> Using cache
18:35:18   ---> 18fa5a32faf3
18:35:18  Step 22/46 : ENV JENKINS_UC https://updates.jenkins.io
18:35:18   ---> Using cache
18:35:18   ---> 5adeb898a5c1
18:35:18  Step 23/46 : ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
18:35:18   ---> Using cache
18:35:18   ---> ffdf5669c574
18:35:18  Step 24/46 : ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
18:35:18   ---> Using cache
18:35:18   ---> 5db49c836455
18:35:18  Step 25/46 : RUN chown -R ${user} "$JENKINS_HOME" "$REF"
18:35:18   ---> Using cache
18:35:18   ---> 8fe218ed80f8
18:35:18  Step 26/46 : RUN git config --global user.name "Volodymyr Kozulenko" && git config --global user.email fenixra73@gmail.com
18:35:18   ---> Using cache
18:35:18   ---> 99ae230b14b5
18:35:18  Step 27/46 : EXPOSE 80
18:35:18   ---> Using cache
18:35:18   ---> 61c77adb5380
18:35:18  Step 28/46 : ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
18:35:18   ---> Using cache
18:35:18   ---> 8fe41ff49d53
18:35:18  Step 29/46 : RUN usermod -aG nginx jenkins
18:35:18   ---> Using cache
18:35:18   ---> 3ffbe26a8175
18:35:18  Step 30/46 : RUN usermod -aG root jenkins
18:35:18   ---> Using cache
18:35:18   ---> 7e89749dbb1c
18:35:18  Step 31/46 : RUN chmod -R 766 /var/log/nginx/
18:35:18   ---> Using cache
18:35:18   ---> bb790efb2ab8
18:35:18  Step 32/46 : RUN chown -R ${user} "$JENKINS_HOME" "$REF"
18:35:18   ---> Using cache
18:35:18   ---> 08bce5ce62ac
18:35:18  Step 33/46 : COPY jenkins-support /usr/local/bin/jenkins-support
18:35:18   ---> Using cache
18:35:18   ---> 59638edf65bb
18:35:18  Step 34/46 : COPY install-plugins.sh /usr/local/bin/install-plugins.sh
18:35:18   ---> Using cache
18:35:18   ---> 2dc4e573db69
18:35:18  Step 35/46 : COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
18:35:18   ---> Using cache
18:35:18   ---> c094326a4339
18:35:18  Step 36/46 : COPY run.sh /usr/local/bin/run.sh
18:35:18   ---> Using cache
18:35:18   ---> 861373a4b7a6
18:35:18  Step 37/46 : USER root
18:35:18   ---> Using cache
18:35:18   ---> 2bb24fdb6b52
18:35:18  Step 38/46 : RUN chmod +x /usr/local/bin/*.sh
18:35:18   ---> Using cache
18:35:18   ---> 355ae82f9f7b
18:35:18  Step 39/46 : USER ${user}
18:35:18   ---> Using cache
18:35:18   ---> 84bcfdc80ba4
18:35:18  Step 40/46 : ENTRYPOINT /usr/local/bin/run.sh
18:35:18   ---> Using cache
18:35:18   ---> ee06537d4945
18:35:18  Step 41/46 : RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
18:35:18   ---> Using cache
18:35:18   ---> 3d9e4f650ad9
18:35:18  Step 42/46 : COPY basic-security.groovy $JENKINS_HOME/init.groovy.d/basic-security.groovy
18:35:18   ---> Using cache
18:35:18   ---> 519b6c80f289
18:35:18  Step 43/46 : COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
18:35:18   ---> Using cache
18:35:18   ---> 08c5b01476b0
18:35:18  Step 44/46 : USER root
18:35:18   ---> Using cache
18:35:18   ---> 6b8555e00c70
18:35:18  Step 45/46 : RUN chown nginx:nginx /etc/nginx/nginx.conf
18:35:18   ---> Using cache
18:35:18   ---> 56811cda7bf3
18:35:18  Step 46/46 : ENTRYPOINT /usr/sbin/nginx && java -jar -Djenkins.install.runSetupWizard=false /usr/share/jenkins/jenkins.war
18:35:18   ---> Using cache
18:35:18   ---> b6ac30519be3
18:35:18  Successfully built b6ac30519be3
18:35:18  Successfully tagged lightlook/cent-jenk-nginx:v8.0
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (docker run)
[Pipeline] echo
18:35:19  ===============docker run container=======================
[Pipeline] dir
18:35:19  Running in /var/lib/jenkins/workspace/1pipeline/task4-jenkins-pipeline1/docker
[Pipeline] {
[Pipeline] sh
18:35:19  + mkdir -p /opt/jenkins_home/
18:35:19  + docker run --rm --name cent-jenk-nginx -d -p80:80 -v /opt/jenkins_home:/var/jenkins_home lightlook/cent-jenk-nginx:v8.0
18:35:20  5da27e3f2572cebb0cee6dcc34891f216f29cfb677ad5a79890265aca7abb9be
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (check running jenkins)
[Pipeline] echo
18:35:22  ===============check running jenkins=======================
[Pipeline] sh
18:35:22  + sleep 80
[Pipeline] sh
18:36:44  + curl http://localhost
18:36:44  + grep -o 'Welcome to Jenkins'
18:36:44    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
18:36:44                                   Dload  Upload   Total   Spent    Left  Speed
18:37:02  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:02 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:03 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:06 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:07 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:08 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:09 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:10 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:11 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:12 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:13 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:14 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:15 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:16 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:17 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:18 --:--:--     0
100 12405  100 12405    0     0    668      0  0:00:18  0:00:18 --:--:--  2739
100 12405  100 12405    0     0    668      0  0:00:18  0:00:18 --:--:--  3516
18:37:02  Welcome to Jenkins
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (stop container)
[Pipeline] echo
18:37:02  ===============stop container jenkins=======================
[Pipeline] sh
18:37:03  + docker stop cent-jenk-nginx
18:37:15  cent-jenk-nginx
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (login to docker hub)
[Pipeline] echo
18:37:15   ============== login to docker hub ==================
[Pipeline] withCredentials
18:37:15  Masking supported pattern matches of $USERNAME or $PASSWORD
[Pipeline] {
[Pipeline] sh
18:37:16  + docker login -u **** -p ****
18:37:16  WARNING! Using --password via the CLI is insecure. Use --password-stdin.
18:37:18  WARNING! Your password will be stored unencrypted in /var/lib/jenkins/.docker/config.json.
18:37:18  Configure a credential helper to remove this warning. See
18:37:18  https://docs.docker.com/engine/reference/commandline/login/#credentials-store
18:37:18  
18:37:18  Login Succeeded
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (docker push)
[Pipeline] echo
18:37:19   ============== start pushing image ==================
[Pipeline] sh
18:37:19  + docker push lightlook/cent-jenk-nginx:v8.0
18:37:19  The push refers to repository [docker.io/lightlook/cent-jenk-nginx]
18:37:20  2c9e272e52ec: Preparing
18:37:20  f9ce5be140d0: Preparing
18:37:20  8be004a20d16: Preparing
18:37:20  57325f38a655: Preparing
18:37:20  1e80ada6ac60: Preparing
18:37:20  96b4a10d0731: Preparing
18:37:20  7ceb4e208477: Preparing
18:37:20  1f099d507e19: Preparing
18:37:20  b2b1a3964a5b: Preparing
18:37:20  e0bfa0e9c5e7: Preparing
18:37:20  a62f025ffdd2: Preparing
18:37:20  a41a2325e080: Preparing
18:37:20  8e5afa5af438: Preparing
18:37:20  98304deb15f6: Preparing
18:37:20  e0bfa0e9c5e7: Preparing
18:37:20  b869482a1960: Preparing
18:37:20  e66e1c99431b: Preparing
18:37:20  70ecf886217e: Preparing
18:37:20  61f6fa70e6b5: Preparing
18:37:20  33f4515dbf67: Preparing
18:37:20  77b174a6a187: Preparing
18:37:20  96b4a10d0731: Waiting
18:37:20  7ceb4e208477: Waiting
18:37:20  1f099d507e19: Waiting
18:37:20  b2b1a3964a5b: Waiting
18:37:20  e0bfa0e9c5e7: Waiting
18:37:20  a62f025ffdd2: Waiting
18:37:20  a41a2325e080: Waiting
18:37:20  8e5afa5af438: Waiting
18:37:20  98304deb15f6: Waiting
18:37:20  b869482a1960: Waiting
18:37:20  e66e1c99431b: Waiting
18:37:20  70ecf886217e: Waiting
18:37:20  61f6fa70e6b5: Waiting
18:37:20  33f4515dbf67: Waiting
18:37:20  77b174a6a187: Waiting
18:37:24  2c9e272e52ec: Pushed
18:37:24  1e80ada6ac60: Pushed
18:37:24  8be004a20d16: Pushed
18:37:25  f9ce5be140d0: Pushed
18:37:29  1f099d507e19: Pushed
18:37:29  b2b1a3964a5b: Pushed
18:37:29  96b4a10d0731: Pushed
18:37:29  7ceb4e208477: Pushed
18:37:33  a62f025ffdd2: Pushed
18:37:33  a41a2325e080: Pushed
18:37:33  e0bfa0e9c5e7: Pushed
18:37:33  8e5afa5af438: Pushed
18:37:36  98304deb15f6: Pushed
18:37:36  e66e1c99431b: Pushed
18:37:37  70ecf886217e: Pushed
18:37:41  77b174a6a187: Mounted from library/centos
18:37:41  61f6fa70e6b5: Pushed
18:38:13  b869482a1960: Pushed
18:38:35  57325f38a655: Pushed
18:38:53  33f4515dbf67: Pushed
18:38:57  v8.0: digest: sha256:5da6674f36f8f78b59790ebe89a48d837f14e77cbe0a31ba6ddb59d4f846cf04 size: 4694
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // timestamps
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
[withMaven] WARNING abort infinite build trigger loop. Please consider opening a Jira issue: Infinite loop of job triggers 
Finished: SUCCESS
```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline1/screenshot/pic1.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline1/screenshot/pic2.png  )


