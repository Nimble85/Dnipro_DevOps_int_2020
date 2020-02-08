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

USER root
RUN chmod +x /usr/local/bin/*.sh

USER ${user}

ENTRYPOINT /usr/local/bin/run.sh

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt


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
Started by user lightlook
Rebuilds build #69
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
Checking out Revision f6fabd1ad1d7dd31f9b2292922fc5c412f33db17 (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f f6fabd1ad1d7dd31f9b2292922fc5c412f33db17 # timeout=10
Commit message: "fix run.sh"
 > git rev-list --no-walk 82bb1705a8e9254b349ae2583298f3f7ca52dadf # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] timestamps
[Pipeline] {
[Pipeline] stage
[Pipeline] { (docker build)
[Pipeline] echo
19:24:38  ===============build image=======================
[Pipeline] dir
19:24:38  Running in /var/lib/jenkins/workspace/1pipeline/task4-jenkins-pipeline1/docker
[Pipeline] {
[Pipeline] sh
19:24:38  + docker build --rm -t lightlook/cent-jenk-nginx:v8.0 .
19:24:38  Sending build context to Docker daemon  32.77kB

19:24:38  Step 1/44 : FROM centos:7
19:24:38   ---> 5e35e350aded
19:24:38  Step 2/44 : RUN yum update -y && yum install -y epel-release && yum install -y git curl net-tools dpkg java java-devel unzip which &&  yum install -y maven  nginx && yum clean all
19:24:38   ---> Using cache
19:24:38   ---> 7fdaae5dc52d
19:24:38  Step 3/44 : ENV JAVA_HOME /etc/alternatives/jre_openjdk
19:24:38   ---> Using cache
19:24:38   ---> 25d0213ce4f5
19:24:38  Step 4/44 : RUN systemctl enable nginx
19:24:38   ---> Using cache
19:24:38   ---> af42a7efe642
19:24:38  Step 5/44 : ARG user=jenkins
19:24:38   ---> Using cache
19:24:38   ---> 369b585a0f1c
19:24:38  Step 6/44 : ARG group=jenkins
19:24:38   ---> Using cache
19:24:38   ---> fb82c5a756d9
19:24:38  Step 7/44 : ARG uid=1000
19:24:38   ---> Using cache
19:24:38   ---> 32887ba4d98c
19:24:38  Step 8/44 : ARG gid=1000
19:24:38   ---> Using cache
19:24:38   ---> d93c89c891a0
19:24:38  Step 9/44 : ARG http_port=8080
19:24:38   ---> Using cache
19:24:38   ---> 79b3ceab948b
19:24:38  Step 10/44 : ARG JENKINS_HOME=/var/jenkins_home
19:24:38   ---> Using cache
19:24:38   ---> 242b39a17f34
19:24:38  Step 11/44 : ARG REF=/usr/share/jenkins/ref
19:24:38   ---> Using cache
19:24:38   ---> daca2141d349
19:24:38  Step 12/44 : ENV JENKINS_HOME $JENKINS_HOME
19:24:38   ---> Using cache
19:24:38   ---> 18ea74530f20
19:24:38  Step 13/44 : ENV REF $REF
19:24:38   ---> Using cache
19:24:38   ---> 6720bb4b5331
19:24:38  Step 14/44 : RUN mkdir -p $JENKINS_HOME   && chown ${uid}:${gid} $JENKINS_HOME   && groupadd -g ${gid} ${group}   && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
19:24:38   ---> Using cache
19:24:38   ---> a6bb25763a91
19:24:38  Step 15/44 : VOLUME $JENKINS_HOME
19:24:38   ---> Using cache
19:24:38   ---> 8ab12b0d1296
19:24:38  Step 16/44 : RUN mkdir -p ${REF}/init.groovy.d
19:24:38   ---> Using cache
19:24:38   ---> fb55c0f2b9c9
19:24:38  Step 17/44 : ARG JENKINS_URL=http://updates.jenkins-ci.org/download/war/2.219/jenkins.war
19:24:38   ---> Using cache
19:24:38   ---> 45fe54e793e0
19:24:38  Step 18/44 : RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war
19:24:38   ---> Using cache
19:24:38   ---> 04a4196bd6d8
19:24:38  Step 19/44 : ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
19:24:38   ---> Using cache
19:24:38   ---> 661afd1ee84a
19:24:38  Step 20/44 : ENV JENKINS_UC https://updates.jenkins.io
19:24:38   ---> Using cache
19:24:38   ---> 8303b2b5bf2a
19:24:38  Step 21/44 : ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
19:24:38   ---> Using cache
19:24:38   ---> 41ff2517d8b2
19:24:38  Step 22/44 : ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
19:24:38   ---> Using cache
19:24:38   ---> 0dca8f729ca0
19:24:38  Step 23/44 : RUN chown -R ${user} "$JENKINS_HOME" "$REF"
19:24:38   ---> Using cache
19:24:38   ---> e2cb8175880b
19:24:38  Step 24/44 : RUN git config --global user.name "Volodymyr Kozulenko" && git config --global user.email fenixra73@gmail.com
19:24:38   ---> Using cache
19:24:38   ---> c344ebdaefaa
19:24:38  Step 25/44 : EXPOSE 80
19:24:38   ---> Using cache
19:24:38   ---> 8af13cb0fd07
19:24:38  Step 26/44 : ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
19:24:38   ---> Using cache
19:24:38   ---> ab3cdb6057d6
19:24:38  Step 27/44 : RUN usermod -aG nginx jenkins
19:24:38   ---> Using cache
19:24:38   ---> 1779ce18458b
19:24:38  Step 28/44 : RUN usermod -aG root jenkins
19:24:38   ---> Using cache
19:24:38   ---> 8b5804c5d3fd
19:24:38  Step 29/44 : RUN chmod -R 766 /var/log/nginx/
19:24:38   ---> Using cache
19:24:38   ---> 6ac106af108c
19:24:38  Step 30/44 : RUN chown -R ${user} "$JENKINS_HOME" "$REF"
19:24:38   ---> Using cache
19:24:38   ---> 43a9196fd9d6
19:24:38  Step 31/44 : COPY jenkins-support /usr/local/bin/jenkins-support
19:24:38   ---> Using cache
19:24:38   ---> 190de8a4ebc0
19:24:38  Step 32/44 : COPY install-plugins.sh /usr/local/bin/install-plugins.sh
19:24:38   ---> Using cache
19:24:38   ---> ee79568da2b2
19:24:38  Step 33/44 : COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
19:24:38   ---> Using cache
19:24:38   ---> ace6b9eea206
19:24:38  Step 34/44 : COPY run.sh /usr/local/bin/run.sh
19:24:39   ---> fb11b0b0990c
19:24:39  Step 35/44 : USER root
19:24:39   ---> Running in 3312730b0703
19:24:40  Removing intermediate container 3312730b0703
19:24:40   ---> ddb962e622c8
19:24:40  Step 36/44 : RUN chmod +x /usr/local/bin/*.sh
19:24:41   ---> Running in 25fc587c7a5e
19:24:43  Removing intermediate container 25fc587c7a5e
19:24:43   ---> af481d9e63f3
19:24:43  Step 37/44 : USER ${user}
19:24:43   ---> Running in 44dc02c6a5bd
19:24:43  Removing intermediate container 44dc02c6a5bd
19:24:43   ---> dd7f957574ab
19:24:43  Step 38/44 : ENTRYPOINT /usr/local/bin/run.sh
19:24:44   ---> Running in 5c2d375ed365
19:24:44  Removing intermediate container 5c2d375ed365
19:24:44   ---> 42dc5ac37982
19:24:44  Step 39/44 : RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
19:24:44   ---> Running in 3e5069005b74
19:24:46  Creating initial locks...
19:24:46  Analyzing war /usr/share/jenkins/jenkins.war...
19:24:46  Registering preinstalled plugins...
19:24:49  Downloading plugins...
19:24:49  Downloading plugin: greenballs from https://updates.jenkins.io/download/plugins/greenballs/latest/greenballs.hpi
19:24:49  Downloading plugin: github-pullrequest from https://updates.jenkins.io/download/plugins/github-pullrequest/latest/github-pullrequest.hpi
19:24:49  Downloading plugin: ssh-slaves from https://updates.jenkins.io/download/plugins/ssh-slaves/latest/ssh-slaves.hpi
19:24:49  Downloading plugin: pipeline-maven from https://updates.jenkins.io/download/plugins/pipeline-maven/latest/pipeline-maven.hpi
19:24:49  Downloading plugin: pipeline-github-lib from https://updates.jenkins.io/download/plugins/pipeline-github-lib/latest/pipeline-github-lib.hpi
19:24:49  Downloading plugin: timestamper from https://updates.jenkins.io/download/plugins/timestamper/latest/timestamper.hpi
19:24:49  Downloading plugin: subversion from https://updates.jenkins.io/download/plugins/subversion/latest/subversion.hpi
19:24:49  Downloading plugin: ws-cleanup from https://updates.jenkins.io/download/plugins/ws-cleanup/latest/ws-cleanup.hpi
19:24:49  Downloading plugin: locale from https://updates.jenkins.io/download/plugins/locale/latest/locale.hpi
19:24:51   > pipeline-github-lib depends on workflow-cps-global-lib:2.5,git:3.0.2
19:24:51  Downloading plugin: workflow-cps-global-lib from https://updates.jenkins.io/download/plugins/workflow-cps-global-lib/latest/workflow-cps-global-lib.hpi
19:24:51  Downloading plugin: git from https://updates.jenkins.io/download/plugins/git/latest/git.hpi
19:24:51   > timestamper depends on workflow-api:2.30,workflow-step-api:2.16
19:24:51   > ssh-slaves depends on credentials:2.3.0,ssh-credentials:1.18,trilead-api:1.0.5
19:24:51   > github-pullrequest depends on github:1.28.1,icon-shim:2.0.3,workflow-api:2.23.1,workflow-multibranch:2.16,workflow-step-api:2.13,block-queued-job:0.2.0;resolution:=optional,branch-api:2.0.16,cloudbees-folder:6.2.1,credentials:2.1.16,email-ext:2.38.2;resolution:=optional,git-client:2.6.0,git:3.6.3,github-api:1.86,job-dsl:1.38;resolution:=optional,jucies:0.2.1;resolution:=optional,mailer:1.18,matrix-project:1.7.1,scm-api:2.2.3,script-security:1.34,ssh-credentials:1.13,structs:1.14;resolution:=optional,token-macro:1.12.1;resolution:=optional,jquery-detached:1.2.1
19:24:51  Downloading plugin: workflow-api from https://updates.jenkins.io/download/plugins/workflow-api/latest/workflow-api.hpi
19:24:51  Downloading plugin: workflow-step-api from https://updates.jenkins.io/download/plugins/workflow-step-api/latest/workflow-step-api.hpi
19:24:51  Downloading plugin: credentials from https://updates.jenkins.io/download/plugins/credentials/latest/credentials.hpi
19:24:51  Downloading plugin: github from https://updates.jenkins.io/download/plugins/github/latest/github.hpi
19:24:51  Downloading plugin: icon-shim from https://updates.jenkins.io/download/plugins/icon-shim/latest/icon-shim.hpi
19:24:51   > pipeline-maven depends on h2-api:1.4.199,mysql-api:8.0.16;resolution:=optional,postgresql-api:42.2.5;resolution:=optional,maven-plugin:3.1.2;resolution:=optional,workflow-api:2.34,workflow-job:2.29,workflow-step-api:2.16,branch-api:2.0.20.1,cloudbees-folder:6.6,config-file-provider:3.5,credentials:2.1.19,htmlpublisher:1.16;resolution:=optional,jacoco:3.0.3;resolution:=optional,jgiven:0.15.1;resolution:=optional,junit-attachments:1.4.2;resolution:=optional,junit:1.26.1;resolution:=optional,matrix-project:1.14;resolution:=optional,maven-invoker-plugin:2.4;resolution:=optional,pipeline-build-step:2.7;resolution:=optional,script-security:1.54.1,structs:1.17,findbugs:4.70;resolution:=optional,tasks:4.51;resolution:=optional
19:24:51  Downloading plugin: ssh-credentials from https://updates.jenkins.io/download/plugins/ssh-credentials/latest/ssh-credentials.hpi
19:24:52  Downloading plugin: trilead-api from https://updates.jenkins.io/download/plugins/trilead-api/latest/trilead-api.hpi
19:24:52  Skipping optional dependency mysql-api
19:24:52  Downloading plugin: h2-api from https://updates.jenkins.io/download/plugins/h2-api/latest/h2-api.hpi
19:24:52  Skipping optional dependency postgresql-api
19:24:52  Skipping optional dependency maven-plugin
19:24:52  Skipping optional dependency block-queued-job
19:24:52  Downloading plugin: workflow-multibranch from https://updates.jenkins.io/download/plugins/workflow-multibranch/latest/workflow-multibranch.hpi
19:24:52  Downloading plugin: branch-api from https://updates.jenkins.io/download/plugins/branch-api/latest/branch-api.hpi
19:24:52  Downloading plugin: workflow-job from https://updates.jenkins.io/download/plugins/workflow-job/latest/workflow-job.hpi
19:24:52  Downloading plugin: cloudbees-folder from https://updates.jenkins.io/download/plugins/cloudbees-folder/latest/cloudbees-folder.hpi
19:24:52  Skipping optional dependency email-ext
19:24:52  Downloading plugin: git-client from https://updates.jenkins.io/download/plugins/git-client/latest/git-client.hpi
19:24:53  Downloading plugin: config-file-provider from https://updates.jenkins.io/download/plugins/config-file-provider/latest/config-file-provider.hpi
19:24:53  Skipping optional dependency htmlpublisher
19:24:53  Skipping optional dependency jacoco
19:24:53  Skipping optional dependency jgiven
19:24:53  Skipping optional dependency job-dsl
19:24:53  Skipping optional dependency junit-attachments
19:24:53  Skipping optional dependency jucies
19:24:53  Skipping optional dependency junit
19:24:53  Downloading plugin: github-api from https://updates.jenkins.io/download/plugins/github-api/latest/github-api.hpi
19:24:53  Skipping optional dependency matrix-project
19:24:53  Skipping optional dependency maven-invoker-plugin
19:24:53  Skipping optional dependency pipeline-build-step
19:24:53  Downloading plugin: mailer from https://updates.jenkins.io/download/plugins/mailer/latest/mailer.hpi
19:24:53  Downloading plugin: matrix-project from https://updates.jenkins.io/download/plugins/matrix-project/latest/matrix-project.hpi
19:24:53  Downloading plugin: script-security from https://updates.jenkins.io/download/plugins/script-security/latest/script-security.hpi
19:24:53  Downloading plugin: scm-api from https://updates.jenkins.io/download/plugins/scm-api/latest/scm-api.hpi
19:24:53  Skipping optional dependency findbugs
19:24:53   > git depends on configuration-as-code:1.35;resolution:=optional,workflow-scm-step:2.9,workflow-step-api:2.20,credentials:2.3.0,git-client:3.0.0,mailer:1.23,matrix-project:1.14;resolution:=optional,parameterized-trigger:2.33;resolution:=optional,promoted-builds:3.2;resolution:=optional,scm-api:2.6.3,script-security:1.66,ssh-credentials:1.17.3,structs:1.20,token-macro:2.10;resolution:=optional
19:24:53  Skipping optional dependency tasks
19:24:53  Downloading plugin: structs from https://updates.jenkins.io/download/plugins/structs/latest/structs.hpi
19:24:53  Skipping optional dependency configuration-as-code
19:24:54  Skipping optional dependency structs
19:24:54  Skipping optional dependency token-macro
19:24:54  Downloading plugin: workflow-scm-step from https://updates.jenkins.io/download/plugins/workflow-scm-step/latest/workflow-scm-step.hpi
19:24:54  Downloading plugin: jquery-detached from https://updates.jenkins.io/download/plugins/jquery-detached/latest/jquery-detached.hpi
19:24:54   > workflow-api depends on workflow-step-api:2.16,scm-api:2.2.6,structs:1.17
19:24:54  Skipping optional dependency matrix-project
19:24:54  Skipping optional dependency parameterized-trigger
19:24:54  Skipping optional dependency promoted-builds
19:24:55   > ws-cleanup depends on workflow-durable-task-step:2.4,matrix-project:1.7.1,resource-disposer:0.3,script-security:1.54,structs:1.19
19:24:55  Downloading plugin: workflow-durable-task-step from https://updates.jenkins.io/download/plugins/workflow-durable-task-step/latest/workflow-durable-task-step.hpi
19:24:55  Skipping optional dependency token-macro
19:24:55   > ssh-credentials depends on credentials:2.2.0,trilead-api:1.0.5
19:24:55  Downloading plugin: resource-disposer from https://updates.jenkins.io/download/plugins/resource-disposer/latest/resource-disposer.hpi
19:24:55   > subversion depends on workflow-scm-step:2.6,credentials:2.1.16,mapdb-api:1.0.9.0,scm-api:2.6.3,ssh-credentials:1.12,structs:1.9
19:24:55   > workflow-step-api depends on structs:1.20
19:24:55   > workflow-multibranch depends on workflow-api:2.27,workflow-cps:2.53,workflow-job:2.21,workflow-scm-step:2.4,workflow-step-api:2.13,workflow-support:2.17,branch-api:2.0.21,cloudbees-folder:6.1.2,scm-api:2.2.7,script-security:1.42,structs:1.17
19:24:56   > workflow-job depends on workflow-api:2.36,workflow-step-api:2.20,workflow-support:3.3
19:24:56   > workflow-cps-global-lib depends on workflow-api:2.33,workflow-cps:2.71,workflow-scm-step:2.7,workflow-step-api:2.20,workflow-support:3.3,cloudbees-folder:6.1.2,credentials:2.1.18,git-server:1.7,scm-api:2.6.3,script-security:1.60,structs:1.19
19:24:56   > cloudbees-folder depends on credentials:2.2.0;resolution:=optional
19:24:56  Skipping optional dependency credentials
19:24:56  Downloading plugin: mapdb-api from https://updates.jenkins.io/download/plugins/mapdb-api/latest/mapdb-api.hpi
19:24:56   > branch-api depends on cloudbees-folder:6.9,scm-api:2.4.1,structs:1.18
19:24:56  Downloading plugin: workflow-cps from https://updates.jenkins.io/download/plugins/workflow-cps/latest/workflow-cps.hpi
19:24:56   > credentials depends on configuration-as-code:1.35;resolution:=optional,structs:1.20
19:24:56  Skipping optional dependency configuration-as-code
19:24:56  Downloading plugin: workflow-support from https://updates.jenkins.io/download/plugins/workflow-support/latest/workflow-support.hpi
19:24:56   > github depends on credentials:2.1.13,display-url-api:2.0,git:3.4.0,github-api:1.90,plain-credentials:1.1,scm-api:2.2.0,structs:1.17,token-macro:1.12.1
19:24:57  Downloading plugin: display-url-api from https://updates.jenkins.io/download/plugins/display-url-api/latest/display-url-api.hpi
19:24:57   > config-file-provider depends on cloudbees-folder:5.12;resolution:=optional,credentials:2.1.4,script-security:1.56,ssh-credentials:1.12,structs:1.14,token-macro:2.0
19:24:57  Skipping optional dependency cloudbees-folder
19:24:57   > workflow-scm-step depends on workflow-step-api:2.9
19:24:57  Downloading plugin: git-server from https://updates.jenkins.io/download/plugins/git-server/latest/git-server.hpi
19:24:57   > mailer depends on display-url-api:2.3.1
19:24:57  Downloading plugin: plain-credentials from https://updates.jenkins.io/download/plugins/plain-credentials/latest/plain-credentials.hpi
19:24:57   > scm-api depends on structs:1.9
19:24:57   > matrix-project depends on junit:1.20,script-security:1.54
19:24:58  Downloading plugin: junit from https://updates.jenkins.io/download/plugins/junit/latest/junit.hpi
19:24:58  Downloading plugin: token-macro from https://updates.jenkins.io/download/plugins/token-macro/latest/token-macro.hpi
19:24:58   > github-api depends on jackson2-api:2.10.2
19:24:58  Downloading plugin: jackson2-api from https://updates.jenkins.io/download/plugins/jackson2-api/latest/jackson2-api.hpi
19:24:59   > git-client depends on configuration-as-code:1.35;resolution:=optional,apache-httpcomponents-client-4-api:4.5.10-1.0,credentials:2.3.0,jsch:0.1.55.1,ssh-credentials:1.17.2,structs:1.20
19:24:59  Skipping optional dependency configuration-as-code
19:24:59  Downloading plugin: apache-httpcomponents-client-4-api from https://updates.jenkins.io/download/plugins/apache-httpcomponents-client-4-api/latest/apache-httpcomponents-client-4-api.hpi
19:24:59  Downloading plugin: jsch from https://updates.jenkins.io/download/plugins/jsch/latest/jsch.hpi
19:24:59   > workflow-durable-task-step depends on workflow-api:2.33,workflow-step-api:2.20,workflow-support:3.3,durable-task:1.33,scm-api:2.2.6,script-security:1.58,structs:1.18
19:24:59  Downloading plugin: durable-task from https://updates.jenkins.io/download/plugins/durable-task/latest/durable-task.hpi
19:24:59   > workflow-support depends on workflow-api:2.36,workflow-step-api:2.20,scm-api:2.2.6,script-security:1.39
19:24:59   > plain-credentials depends on credentials:2.2.0
19:25:00   > git-server depends on git-client:2.7.6
19:25:00   > workflow-cps depends on workflow-api:2.36,workflow-scm-step:2.4,workflow-step-api:2.21,workflow-support:3.3,scm-api:2.2.6,script-security:1.63,structs:1.20,support-core:2.43;resolution:=optional,ace-editor:1.0.1,jquery-detached:1.2.1
19:25:00  Skipping optional dependency support-core
19:25:00  Downloading plugin: ace-editor from https://updates.jenkins.io/download/plugins/ace-editor/latest/ace-editor.hpi
19:25:00   > junit depends on workflow-api:2.34,workflow-step-api:2.19,script-security:1.56,structs:1.17
19:25:00   > token-macro depends on workflow-step-api:2.14,structs:1.14
19:25:01   > jsch depends on ssh-credentials:1.14,trilead-api:1.0.5
19:25:03  
19:25:03  WAR bundled plugins:
19:25:03  
19:25:03  
19:25:03  Installed plugins:
19:25:03  ace-editor:1.1
19:25:03  apache-httpcomponents-client-4-api:4.5.10-2.0
19:25:03  branch-api:2.5.5
19:25:03  cloudbees-folder:6.11.1
19:25:03  config-file-provider:3.6.3
19:25:03  credentials:2.3.1
19:25:03  display-url-api:2.3.2
19:25:03  durable-task:1.33
19:25:03  git-client:3.1.1
19:25:03  git-server:1.9
19:25:03  git:4.1.1
19:25:03  github-api:1.106
19:25:03  github-pullrequest:0.2.6
19:25:03  github:1.29.5
19:25:03  greenballs:1.15
19:25:03  h2-api:1.4.199
19:25:03  icon-shim:2.0.3
19:25:03  jackson2-api:2.10.2
19:25:03  jquery-detached:1.2.1
19:25:03  jsch:0.1.55.2
19:25:03  junit:1.28
19:25:04  locale:1.4
19:25:04  mailer:1.30
19:25:04  mapdb-api:1.0.9.0
19:25:04  matrix-project:1.14
19:25:04  pipeline-github-lib:1.0
19:25:04  pipeline-maven:3.8.2
19:25:04  plain-credentials:1.7
19:25:04  resource-disposer:0.14
19:25:04  scm-api:2.6.3
19:25:04  script-security:1.69
19:25:04  ssh-credentials:1.18.1
19:25:04  ssh-slaves:1.31.1
19:25:04  structs:1.20
19:25:04  subversion:2.13.0
19:25:04  timestamper:1.10
19:25:04  token-macro:2.10
19:25:04  trilead-api:1.0.5
19:25:04  workflow-api:2.39
19:25:04  workflow-cps-global-lib:2.15
19:25:04  workflow-cps:2.78
19:25:04  workflow-durable-task-step:2.35
19:25:04  workflow-job:2.36
19:25:04  workflow-multibranch:2.21
19:25:04  workflow-scm-step:2.10
19:25:04  workflow-step-api:2.22
19:25:04  workflow-support:3.4
19:25:04  ws-cleanup:0.38
19:25:04  Cleaning up locks
19:25:09  Removing intermediate container 3e5069005b74
19:25:09   ---> 336eed061aab
19:25:09  Step 40/44 : COPY basic-security.groovy $JENKINS_HOME/init.groovy.d/basic-security.groovy
19:25:09   ---> d7356b2acd4e
19:25:09  Step 41/44 : COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
19:25:10   ---> 249938405efd
19:25:10  Step 42/44 : USER root
19:25:10   ---> Running in 7844a6c87095
19:25:11  Removing intermediate container 7844a6c87095
19:25:11   ---> a492b47beae2
19:25:11  Step 43/44 : RUN chown nginx:nginx /etc/nginx/nginx.conf
19:25:11   ---> Running in aa54d1720721
19:25:13  Removing intermediate container aa54d1720721
19:25:13   ---> 08564d922628
19:25:13  Step 44/44 : ENTRYPOINT /usr/local/bin/run.sh
19:25:14   ---> Running in 2ca2074134f1
19:25:14  Removing intermediate container 2ca2074134f1
19:25:14   ---> 56eb91a4ea4d
19:25:14  Successfully built 56eb91a4ea4d
19:25:14  Successfully tagged lightlook/cent-jenk-nginx:v8.0
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (docker run)
[Pipeline] echo
19:25:15  ===============docker run container=======================
[Pipeline] dir
19:25:15  Running in /var/lib/jenkins/workspace/1pipeline/task4-jenkins-pipeline1/docker
[Pipeline] {
[Pipeline] sh
19:25:15  + mkdir -p /opt/jenkins_home/
19:25:15  + docker run --rm --name cent-jenk-nginx -d -p80:80 -v /opt/jenkins_home:/var/jenkins_home lightlook/cent-jenk-nginx:v8.0
19:25:16  47ac1967cf2bb840a9f4d677eddd0053736c5d4a70c77824812125a6cbd42eed
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (check running jenkins)
[Pipeline] echo
19:25:19  ===============check running jenkins=======================
[Pipeline] sh
19:25:20  + sleep 80
[Pipeline] sh
19:26:41  + curl http://localhost
19:26:41  + grep -o 'Welcome to Jenkins'
19:26:41    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
19:26:41                                   Dload  Upload   Total   Spent    Left  Speed
19:27:00  
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
100 12405  100 12405    0     0    660      0  0:00:18  0:00:18 --:--:--  2597
100 12405  100 12405    0     0    660      0  0:00:18  0:00:18 --:--:--  3286
19:27:00  Welcome to Jenkins
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (stop container)
[Pipeline] echo
19:27:01  ===============stop container jenkins=======================
[Pipeline] sh
19:27:01  + docker stop cent-jenk-nginx
19:27:13  cent-jenk-nginx
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (login to docker hub)
[Pipeline] echo
19:27:14   ============== login to docker hub ==================
[Pipeline] withCredentials
19:27:14  Masking supported pattern matches of $USERNAME or $PASSWORD
[Pipeline] {
[Pipeline] sh
19:27:14  + docker login -u **** -p ****
19:27:14  WARNING! Using --password via the CLI is insecure. Use --password-stdin.
19:27:16  WARNING! Your password will be stored unencrypted in /var/lib/jenkins/.docker/config.json.
19:27:16  Configure a credential helper to remove this warning. See
19:27:16  https://docs.docker.com/engine/reference/commandline/login/#credentials-store
19:27:16  
19:27:16  Login Succeeded
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (docker push)
[Pipeline] echo
19:27:17   ============== start pushing image ==================
[Pipeline] sh
19:27:17  + docker push lightlook/cent-jenk-nginx:v8.0
19:27:17  The push refers to repository [docker.io/lightlook/cent-jenk-nginx]
19:27:18  51fef5b0921f: Preparing
19:27:18  1dadfe59e3ef: Preparing
19:27:18  3820fe4fe43e: Preparing
19:27:18  074ee09e5ba0: Preparing
19:27:18  5963522624dc: Preparing
19:27:18  ae1f44c4d432: Preparing
19:27:18  eca82ec7978e: Preparing
19:27:18  df4bca35d4bc: Preparing
19:27:18  b824a22215ae: Preparing
19:27:18  368efb24d55e: Preparing
19:27:18  a62f025ffdd2: Preparing
19:27:18  4d82ea305b38: Preparing
19:27:18  e40453b0f415: Preparing
19:27:18  58234d278c67: Preparing
19:27:18  368efb24d55e: Preparing
19:27:18  a3997573b85a: Preparing
19:27:18  e66e1c99431b: Preparing
19:27:18  70ecf886217e: Preparing
19:27:18  61f6fa70e6b5: Preparing
19:27:18  33f4515dbf67: Preparing
19:27:18  77b174a6a187: Preparing
19:27:18  ae1f44c4d432: Waiting
19:27:18  eca82ec7978e: Waiting
19:27:18  df4bca35d4bc: Waiting
19:27:18  b824a22215ae: Waiting
19:27:18  368efb24d55e: Waiting
19:27:18  a62f025ffdd2: Waiting
19:27:18  4d82ea305b38: Waiting
19:27:18  e40453b0f415: Waiting
19:27:18  58234d278c67: Waiting
19:27:18  a3997573b85a: Waiting
19:27:18  e66e1c99431b: Waiting
19:27:18  70ecf886217e: Waiting
19:27:18  77b174a6a187: Waiting
19:27:18  33f4515dbf67: Waiting
19:27:18  61f6fa70e6b5: Waiting
19:27:23  5963522624dc: Pushed
19:27:23  51fef5b0921f: Pushed
19:27:23  3820fe4fe43e: Pushed
19:27:23  1dadfe59e3ef: Pushed
19:27:26  eca82ec7978e: Pushed
19:27:26  ae1f44c4d432: Pushed
19:27:27  df4bca35d4bc: Pushed
19:27:27  a62f025ffdd2: Layer already exists
19:27:27  b824a22215ae: Pushed
19:27:30  4d82ea305b38: Pushed
19:27:30  368efb24d55e: Pushed
19:27:31  e40453b0f415: Pushed
19:27:31  58234d278c67: Pushed
19:27:32  e66e1c99431b: Layer already exists
19:27:32  70ecf886217e: Layer already exists
19:27:32  61f6fa70e6b5: Layer already exists
19:27:33  33f4515dbf67: Layer already exists
19:27:33  77b174a6a187: Layer already exists
19:27:39  074ee09e5ba0: Pushed
19:27:49  a3997573b85a: Pushed
19:27:53  v8.0: digest: sha256:1ce9425db29f5de1036bc8d95aaa3c6782a56f388c7bbcba009c99ee47fa6b5e size: 4694
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
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline1/screenshot/pic3.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline1/screenshot/pic4.png  )


