# Task 
```
1.	Сборка докер имеджа и пуш на свой аккаунт на докер хабе (https://hub.docker.com) или в GitLab Repository (приветствуется этот вариант). Прикладываю описание имеджа, но можно использовать тот, что вы делали в ДЗ по докеру:
Jenkins CI сервер на основе Ubuntu – стандартная инсталляция Jenkins + java+ Maven (для будущего актифактори). 
Создать пользователя jenkins с привелегиями управления сервером CI.
Бонусное задание (nice to have😊): установить в этот же контейнер nginx и использовать его как прокси, т.е. стучаться на Jenkins server через nginx.
Протестировать  работу вашего Jenkins контейнера отдельным стейджем после сборки (в той же пайплайне). Т.е. curl/wget проверить соединение в райнтайме (или любой другой способ).
Любые ваши дополнения или улучшения приветствуются.
```
# Solution

The task will be done using Gitlab free runners

## Steps:
```
1. Stage 1 - build two images. Main image and small image for tests. Image for run tests based on Alpine linux and cURL
             pull both images to DOCKERHUB
2. Stage 2 - test running Jenkins
   a - pull both images (main and test)
   b - run container with Jenkins from main image
   с - create network for link both containers
   d - connect container with Jenkins to created above network
   e - run container  test tool with connect to test network . 

3. Stage 3 - Pull tested tagged main image, login to dockerhub and push image without tags (latest)
```
# Gitlab repo
https://gitlab.com/lightlook/gitlab-ci-1-v2


## File .gitlab-ci.yml
```
image: docker
services:
  - docker:dind

variables:
  NAME_CONTAINER: 'cent-jenk-nginx' # name main container 
  NAME_TEST_CONTAINER: 'alpine-curl' # name  container for run tests
  BUILD_VERSION: 'v9.0'
  PROJECT: 'gitlab-ci-1-v2'
  PORT_EXT: '80'
  PORT_INT: '80'
  CURL_URL: 'http://${NAME_CONTAINER}'
  NETWORK: 'test-network'
  JENKINS_HOME: '/var/jenkins_home'
  NAME_IMGAGE: '${GITHUB_USERNAME}/${NAME_CONTAINER}'
  NAME_TEST_IMAGE: '${GITHUB_USERNAME}/${NAME_TEST_CONTAINER}'
  FOLDER_HOST: '/builds/lightlook/${PROJECT}/jenkins_home' # folder on host for storing jenkins_home
 
stages:
  - build
  - test
  - deploy

Create image:
  stage: build
  when: manual
     
  script:
    - "docker build -t ${NAME_IMGAGE}:${BUILD_VERSION} ." # build main image 
    - "docker build -t ${NAME_TEST_IMAGE} ./test-image" # build image alpine with curl
    - "docker login -u ${GITHUB_USERNAME} -p ${GITHUB_PASSWORD}"
    - "docker push ${NAME_IMGAGE}:${BUILD_VERSION}"
    - "docker push ${NAME_TEST_IMAGE}"
 
Test container:
  stage: test
  when: manual

  script:
    - "docker pull ${NAME_IMGAGE}:${BUILD_VERSION}"
    - "docker pull ${NAME_TEST_IMAGE}"
    - "mkdir -p ${FOLDER_HOST}; docker run  --name ${NAME_CONTAINER} -d -p ${PORT_EXT}:${PORT_INT} -v ${FOLDER_HOST}:${JENKINS_HOME}  ${NAME_IMGAGE}:${BUILD_VERSION}"
    - "docker network create ${NETWORK} " #create networ for test
    - "docker network connect ${NETWORK} ${NAME_CONTAINER}" # connect main container to test network
    - "sleep 30"
    - "docker run --network ${NETWORK} ${NAME_TEST_IMAGE} ${CURL_URL} "  #  run test container for testing main container

Push:
  stage: deploy
  when: manual
 
  script: 
    - "docker pull ${NAME_IMGAGE}:${BUILD_VERSION}"
    - "docker login -u ${GITHUB_USERNAME} -p ${GITHUB_PASSWORD}"
    - "docker push ${NAME_IMGAGE}"
```
## Build stage log
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1-shared-runners/screenshot/pic1.png  )


## Test stage log

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1-shared-runners/screenshot/pic2.png  )

## Push stage log 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1-shared-runners/screenshot/pic3.png  )

## Pipelines log
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1-shared-runners/screenshot/pic4.png  )


## DockerHub

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1-shared-runners/screenshot/pic5.png  )
