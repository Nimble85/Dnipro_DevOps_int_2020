# Task
```
2.	Сборка и тестирование  проекта (Java, JS, etc.):
- Собрать проект из вашего репозитория GitLab.
- Протестировать работу приоложения.
```

# Solution

## Steps

1. Install local on-premises gitlab_runner and connect his to gilab
2. Stage 1 - build by maven war file and put it  in to docker image and run container
3. Stage 2 - Test aplication for runing and arifmetic functional and stop container
4. Stage 3 - login to dockerhub and push image

## File .gitlab-ci.yml
```
variables:
    REPO: https://gitlab.com/lightlook/gitlab-ci-2.git
    WORK_DIR: gitlab-ci-2
    NAME_IMGAGE: lightlook/java-wecalc
    NAME_CONTAINER: java-webcalc
    BUILD_VERSION: latest
   
stages:
  - build
  - test
  - deploy
 
Create image:
  stage: build
  when: manual # run only manual, without automatic run after commits
  tags: 
    - build # tags for my local gitlab_runner
  before_script:
    - docker info
    - whoami
    - "rm -rf .git" # clearing .git folder, without this stage had failure
      
  script:
    - "rm -rf ~/${WORK_DIR}; mkdir -p ~/${WORK_DIR};  git init; git clone  ${REPO}; cd ${WORK_DIR}; mvn clean package -Dmaven.test.skip=true; docker build --rm -t ${NAME_IMGAGE}:${BUILD_VERSION} ."
    - "docker run --rm -d --name java-webcalc -p 8081:8080 -p 8009:8009 ${NAME_IMGAGE}:${BUILD_VERSION}"
    
Test container:
  stage: test
  when: on_success  # run only if previos stage had success
  tags: 
    - test # tags for my local gitlab_runner
  before_script: 
    - "rm -rf .git" # clearing .git folder, without this stage had failure
    - sleep 80
  script:
    - curl  http://localhost:8081/api/calculator/ping | grep -o 'Welcome to Java Maven Calculator Web App'
    - curl  "http://localhost:8081/api/calculator/add?x=8&y=26" | grep -o '"result":34'
    - curl  "http://localhost:8081/api/calculator/sub?x=12&y=8" | grep -o '"result":4'
    - curl  "http://localhost:8081/api/calculator/mul?x=11&y=8" | grep -o '"result":88'
    - curl  "http://localhost:8081/api/calculator/div?x=12&y=12"| grep -o '"result":1'
    - "docker stop ${NAME_CONTAINER}" 
  # push to docker hub
Push:  
  stage: deploy
  when: on_success # run only if previos stage had success
  tags: 
    - deploy # tags for my local gitlab_runner
  before_script: 
    - "rm -rf .git"    # clearing .git folder, without this stage had failure
  script: 
    - "docker login -u ${GITHUB_USERNAME} -p ${GITHUB_PASSWORD}"
    - "docker push ${NAME_IMGAGE}:${BUILD_VERSION}"
```
## Build stage log
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic1.png  )


## Test stage log

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic2.png  )

## Push stage log 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic3.png  )

## Pipelines log
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic4.png  )

## Pipeline view

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic5.png  )

## On premises runner

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic6.png  )


## DockerHub

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline2/screenshot/pic7.png  )
