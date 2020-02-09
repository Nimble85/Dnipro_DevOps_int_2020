# Task
```
2.	Сборка и тестирование  проекта (Java, JS, etc.):
- Собрать проект из любого Git репозитория используя.
- Протестировать работу приоложения.
```
## Solution
For base  will be used   Java WebCalc application from  github
https://github.com/maping/java-maven-calculator-web-app.git

Steps:
1. Assembling webapp WAR file
2. Put WAR-file in the docker container- tomcat
3. Run container
4. Test aplication for runing and arifmetic functional
5. Stop container
6. Login to Docker Hub
7. Push image to docker hub repositories
8. Post build actions on FAILURE - stop docker container

# second-pipeline.jenkins
```
#!groovy
// Run docker build
properties([disableConcurrentBuilds()])

pipeline {
    agent { 
        label 'master'
        }
    options {
        buildDiscarder(logRotator(numToKeepStr: '2', artifactNumToKeepStr: '2'))
        timestamps()
    }
  
    stages {
        stage("build maven app") {
            steps {
                echo "===============build maven app======================="
                dir ("task4-jenkins-pipeline2") {
                sh 'mvn clean package -Dmaven.test.skip=true'
                }
            }
        }   
        stage("buil docker container with app ") {
            steps {
                echo "===============build container calc======================="
                dir ("task4-jenkins-pipeline2") {
                sh 'docker build --rm -t lightlook/java-wecalc:v1.0 .'
                }                 
            }    
        }
        stage("run webcalc container") {
            steps {
                echo "===============run webcalc container======================="
                sh 'docker run --rm -d --name java-webcalc -p 8081:8080 -p 8009:8009  lightlook/java-wecalc:v1.0'
                                
            }    
         }
        stage("test running webcalc") {
            steps {
                echo "===============testing running calc======================="
                sh 'sleep 30'
                sh '''
                    #!/bin/bash
                    curl  http://localhost:8081/api/calculator/ping | grep -o 'Welcome to Java Maven Calculator Web App'
                    curl  "http://localhost:8081/api/calculator/add?x=8&y=26" | grep -o '"result":34'
                    curl  "http://localhost:8081/api/calculator/sub?x=12&y=8" | grep -o '"result":4'
                    curl  "http://localhost:8081/api/calculator/mul?x=11&y=8" | grep -o '"result":88'
                    curl  "http://localhost:8081/api/calculator/div?x=12&y=12"| grep -o '"result":1'

                '''
                echo "===============check calc passed=======================" 
            }    

        }
       
        stage("stop container") {
            steps {
                echo "===============stop container jenkins======================="
                sh 'docker stop java-webcalc'
                                
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
                sh   'docker push lightlook/java-wecalc:v1.0'
            }
        }
    }    
    post { 
        failure { 
            echo "==============stop container after failure build==============="
            sh 'docker stop java-webcalc'
        }
    }
    
}    
    

```

# Pipeline log
```
Started by user lightlook
Rebuilds build #28
Obtained task4-jenkins-pipeline2/jenkins/second-pipeline.jenkins from git https://github.com/fenixra73/Dnipro_DevOps_int_2020.git
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] properties
[Pipeline] node
Running on Jenkins in /var/lib/jenkins/workspace/2pipeline
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
Checking out Revision 7c7d073253268176b503a6b77667928a4807fac6 (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 7c7d073253268176b503a6b77667928a4807fac6 # timeout=10
Commit message: "fix"
 > git rev-list --no-walk 42210cc30bd912704300f52e64b35ee9b67dec48 # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] timestamps
[Pipeline] {
[Pipeline] stage
[Pipeline] { (build maven app)
[Pipeline] echo
21:18:19  ===============build maven app=======================
[Pipeline] dir
21:18:19  Running in /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2
[Pipeline] {
[Pipeline] sh
21:18:20  + mvn clean package -Dmaven.test.skip=true
21:18:23  [INFO] Scanning for projects...
21:18:23  [INFO]                                                                         
21:18:23  [INFO] ------------------------------------------------------------------------
21:18:23  [INFO] Building Calculator Web 1.1-SNAPSHOT
21:18:23  [INFO] ------------------------------------------------------------------------
21:18:27  [INFO] 
21:18:27  [INFO] --- maven-clean-plugin:2.4.1:clean (default-clean) @ java-maven-calculator-web-app ---
21:18:27  [INFO] Deleting /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/target
21:18:27  [INFO] 
21:18:27  [INFO] --- maven-resources-plugin:2.5:resources (default-resources) @ java-maven-calculator-web-app ---
21:18:27  [debug] execute contextualize
21:18:27  [INFO] Using 'UTF-8' encoding to copy filtered resources.
21:18:27  [INFO] skip non existing resourceDirectory /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/src/main/resources
21:18:27  [INFO] 
21:18:27  [INFO] --- maven-compiler-plugin:3.8.0:compile (default-compile) @ java-maven-calculator-web-app ---
21:18:29  [INFO] Changes detected - recompiling the module!
21:18:29  [INFO] Compiling 2 source files to /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/target/classes
21:18:31  [INFO] 
21:18:31  [INFO] --- maven-resources-plugin:2.5:testResources (default-testResources) @ java-maven-calculator-web-app ---
21:18:31  [debug] execute contextualize
21:18:31  [INFO] Using 'UTF-8' encoding to copy filtered resources.
21:18:31  [INFO] skip non existing resourceDirectory /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/src/test/resources
21:18:31  [INFO] 
21:18:31  [INFO] --- maven-compiler-plugin:3.8.0:testCompile (default-testCompile) @ java-maven-calculator-web-app ---
21:18:31  [INFO] Not compiling test sources
21:18:31  [INFO] 
21:18:31  [INFO] --- maven-surefire-plugin:2.22.0:test (default-test) @ java-maven-calculator-web-app ---
21:18:31  [INFO] Tests are skipped.
21:18:31  [INFO] 
21:18:31  [INFO] >>> cobertura-maven-plugin:2.7:cobertura (cobertura) @ java-maven-calculator-web-app >>>
21:18:31  [INFO] 
21:18:31  [INFO] --- maven-resources-plugin:2.5:resources (default-resources) @ java-maven-calculator-web-app ---
21:18:31  [debug] execute contextualize
21:18:31  [INFO] Using 'UTF-8' encoding to copy filtered resources.
21:18:31  [INFO] skip non existing resourceDirectory /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/src/main/resources
21:18:31  [INFO] 
21:18:31  [INFO] --- maven-compiler-plugin:3.8.0:compile (default-compile) @ java-maven-calculator-web-app ---
21:18:31  [INFO] Nothing to compile - all classes are up to date
21:18:31  [INFO] 
21:18:31  [INFO] --- cobertura-maven-plugin:2.7:instrument (cobertura) @ java-maven-calculator-web-app ---
21:18:37  [INFO] Cobertura 2.1.1 - GNU GPL License (NO WARRANTY) - See COPYRIGHT file
21:18:37  [INFO] Cobertura: Saved information on 2 classes.
21:18:37  [INFO] Cobertura: Saved information on 2 classes.
21:18:37  
21:18:37  [INFO] Instrumentation was successful.
21:18:37  [INFO] NOT adding cobertura ser file to attached artifacts list.
21:18:37  [INFO] 
21:18:37  [INFO] --- maven-resources-plugin:2.5:testResources (default-testResources) @ java-maven-calculator-web-app ---
21:18:37  [debug] execute contextualize
21:18:37  [INFO] Using 'UTF-8' encoding to copy filtered resources.
21:18:37  [INFO] skip non existing resourceDirectory /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/src/test/resources
21:18:37  [INFO] 
21:18:37  [INFO] --- maven-compiler-plugin:3.8.0:testCompile (default-testCompile) @ java-maven-calculator-web-app ---
21:18:37  [INFO] Not compiling test sources
21:18:37  [INFO] 
21:18:37  [INFO] --- maven-surefire-plugin:2.22.0:test (default-test) @ java-maven-calculator-web-app ---
21:18:37  [INFO] Tests are skipped.
21:18:37  [INFO] 
21:18:37  [INFO] <<< cobertura-maven-plugin:2.7:cobertura (cobertura) @ java-maven-calculator-web-app <<<
21:18:37  [INFO] 
21:18:37  [INFO] --- cobertura-maven-plugin:2.7:cobertura (cobertura) @ java-maven-calculator-web-app ---
21:18:39  [INFO] Cobertura 2.1.1 - GNU GPL License (NO WARRANTY) - See COPYRIGHT file
21:18:39  [INFO] Cobertura: Loaded information on 2 classes.
21:18:39  Report time: 497ms
21:18:39  
21:18:39  [INFO] Cobertura Report generation was successful.
21:18:41  [INFO] Cobertura 2.1.1 - GNU GPL License (NO WARRANTY) - See COPYRIGHT file
21:18:41  [INFO] Cobertura: Loaded information on 2 classes.
21:18:41  Report time: 516ms
21:18:41  
21:18:41  [INFO] Cobertura Report generation was successful.
21:18:41  [INFO] 
21:18:41  [INFO] --- maven-war-plugin:3.2.2:war (default-war) @ java-maven-calculator-web-app ---
21:18:42  [INFO] Packaging webapp
21:18:42  [INFO] Assembling webapp [java-maven-calculator-web-app] in [/var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/target/calculator]
21:18:42  [INFO] Processing war project
21:18:42  [INFO] Copying webapp resources [/var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/src/main/webapp]
21:18:42  [INFO] Webapp assembled in [332 msecs]
21:18:42  [INFO] Building war: /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2/target/calculator.war
21:18:43  [INFO] ------------------------------------------------------------------------
21:18:43  [INFO] BUILD SUCCESS
21:18:43  [INFO] ------------------------------------------------------------------------
21:18:43  [INFO] Total time: 20.006s
21:18:43  [INFO] Finished at: Sun Feb 09 21:18:43 EET 2020
21:18:44  [INFO] Final Memory: 24M/182M
21:18:44  [INFO] ------------------------------------------------------------------------
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (buil docker container with app )
[Pipeline] echo
21:18:44  ===============build container calc=======================
[Pipeline] dir
21:18:44  Running in /var/lib/jenkins/workspace/2pipeline/task4-jenkins-pipeline2
[Pipeline] {
[Pipeline] sh
21:18:45  + docker build --rm -t lightlook/java-wecalc:v1.0 .
21:18:45  Sending build context to Docker daemon   17.1MB

21:18:45  Step 1/4 : FROM tomcat
21:18:45   ---> b56d8850aed5
21:18:45  Step 2/4 : LABEL maintainer="Kozulenko Volodymyr"
21:18:45   ---> Using cache
21:18:45   ---> 7cda1d8d7d11
21:18:45  Step 3/4 : RUN rm -rf $CATALINA_HOME/webapps/ROOT
21:18:45   ---> Using cache
21:18:45   ---> 2b5a9773f29c
21:18:45  Step 4/4 : COPY target/calculator.war $CATALINA_HOME/webapps/ROOT.war
21:18:48   ---> 5002cf6d535f
21:18:48  Successfully built 5002cf6d535f
21:18:48  Successfully tagged lightlook/java-wecalc:v1.0
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (run webcalc container)
[Pipeline] echo
21:18:48  ===============run webcalc container=======================
[Pipeline] sh
21:18:49  + docker run --rm -d --name java-webcalc -p 8081:8080 -p 8009:8009 lightlook/java-wecalc:v1.0
21:18:49  9e9cb0f64b5fb53b1417637b78a67cd81438c07bddec74b2b460decf922d994f
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (test running webcalc)
[Pipeline] echo
21:18:51  ===============testing running calc=======================
[Pipeline] sh
21:18:51  + sleep 30
[Pipeline] sh
21:19:23  + grep -o 'Welcome to Java Maven Calculator Web App'
21:19:23  + curl http://localhost:8081/api/calculator/ping
21:19:23    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
21:19:23                                   Dload  Upload   Total   Spent    Left  Speed
21:19:24  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    72  100    72    0     0    119      0 --:--:-- --:--:-- --:--:--   120
100    72  100    72    0     0    119      0 --:--:-- --:--:-- --:--:--   119
21:19:24  Welcome to Java Maven Calculator Web App
21:19:24  + curl 'http://localhost:8081/api/calculator/add?x=8&y=26'
21:19:24  + grep -o '"result":34'
21:19:24    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
21:19:24                                   Dload  Upload   Total   Spent    Left  Speed
21:19:25  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    64  100    64    0     0     85      0 --:--:-- --:--:-- --:--:--    85
100    64  100    64    0     0     85      0 --:--:-- --:--:-- --:--:--    85
21:19:25  "result":34
21:19:25  + grep -o '"result":4'
21:19:25  + curl 'http://localhost:8081/api/calculator/sub?x=12&y=8'
21:19:25    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
21:19:25                                   Dload  Upload   Total   Spent    Left  Speed
21:19:25  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    63  100    63    0     0   3374      0 --:--:-- --:--:-- --:--:--  3500
21:19:25  "result":4
21:19:25  + curl 'http://localhost:8081/api/calculator/mul?x=11&y=8'
21:19:25  + grep -o '"result":88'
21:19:25    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
21:19:25                                   Dload  Upload   Total   Spent    Left  Speed
21:19:25  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    64  100    64    0     0   3363      0 --:--:-- --:--:-- --:--:--  3555
21:19:25  "result":88
21:19:25  + curl 'http://localhost:8081/api/calculator/div?x=12&y=12'
21:19:25  + grep -o '"result":1'
21:19:25    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
21:19:25                                   Dload  Upload   Total   Spent    Left  Speed
21:19:25  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    64  100    64    0     0   3393      0 --:--:-- --:--:-- --:--:--  3555
21:19:25  "result":1
[Pipeline] echo
21:19:25  ===============check calc passed=======================
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (stop container)
[Pipeline] echo
21:19:25  ===============stop container jenkins=======================
[Pipeline] sh
21:19:25  + docker stop java-webcalc
21:19:27  java-webcalc
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (login to docker hub)
[Pipeline] echo
21:19:27   ============== login to docker hub ==================
[Pipeline] withCredentials
21:19:29  Masking supported pattern matches of $USERNAME or $PASSWORD
[Pipeline] {
[Pipeline] sh
21:19:29  + docker login -u **** -p ****
21:19:29  WARNING! Using --password via the CLI is insecure. Use --password-stdin.
21:19:31  WARNING! Your password will be stored unencrypted in /var/lib/jenkins/.docker/config.json.
21:19:31  Configure a credential helper to remove this warning. See
21:19:31  https://docs.docker.com/engine/reference/commandline/login/#credentials-store
21:19:31  
21:19:31  Login Succeeded
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (docker push)
[Pipeline] echo
21:19:31   ============== start pushing image ==================
[Pipeline] sh
21:19:32  + docker push lightlook/java-wecalc:v1.0
21:19:32  The push refers to repository [docker.io/lightlook/java-wecalc]
...
cut
...
21:19:46  d29a8c741ade: Pushed
21:19:52  v1.0: digest: sha256:5e31484cb831da9c3a0ec653b95e5f2bb6d5d120dfde23a0d5102d5005787e2e size: 2632
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
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline2/screenshot/pic1.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline2/screenshot/pic2.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-jenkins-pipeline2/screenshot/pic3.png  )

