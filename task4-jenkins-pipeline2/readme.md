# Task
```
2.	Сборка и тестирование  проекта (Java, JS, etc.):
- Собрать проект из любого Git репозитория используя.
- Протестировать работу приоложения.
```
## Solution
For base java application will be use Java WebCalc repo github
https://github.com/maping/java-maven-calculator-web-app.git

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
                sh 'mvn clean package -Dmaven.test.skip=true'
          
            }
        }   
        stage("buil docker container with app ") {
            steps {
                echo "===============build container calc======================="
                sh 'docker build --rm -t lightlook/java-wecalc:v1.0 .'
                                
            }    
        }
        stage("run webcalc container") {
            steps {
                echo "===============run container jenkins======================="
                sh 'docker run --rm --name java-webcalc -p 8081:8080 -p 8009:8009  lightlook/java-wecalc:v1.0'
                                
            }    
         }
        stage("test running webcalc") {
            steps {
                echo "===============check running calc======================="
                sh 'sleep 60'
                sh 'curl 'http://localhost:8081/api/calculator/ping' | grep -o 'Welcome to Java Maven Calculator Web App!!!''
                sh 'curl 'http://localhost:8081/api/calculator/add?x=8&y=26' | grep -o '"result":34''
                sh 'curl ''http://localhost:8081/api/calculator/sub?x=12&y=8' | grep -o '"result":4''
                sh 'curl 'http://localhost:8081/api/calculator/mul?x=11&y=8' | grep -o '"result":88''
                sh 'curl 'http://localhost:8081/api/calculator/div?x=12&y=12'| grep -o '"result":1''
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


   
}

    

```