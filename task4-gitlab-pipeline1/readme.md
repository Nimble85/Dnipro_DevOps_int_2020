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

## Steps:
1. Install local on-premises gitlab_runner and connect his to gilab
2. Stage 1 - build docker image and run container
3. Stage 2 - test for running Jenkins and stop container
4. Stage 3 - login to dockerhub and push image

# Gitlab repo
https://gitlab.com/lightlook/gitlab-ci-1


## File .gitlab-ci.yml
```
variables:
    REPO: https://gitlab.com/lightlook/gitlab-ci-1.git
    WORK_DIR: gitlab-ci-1
    NAME_IMGAGE: lightlook/cent-jenk-nginx
    NAME_CONTAINER: cent-jenk-nginx
    BUILD_VERSION: latest
  
  stages:
    - build
    - test
    - deploy
  before_script:
    - "rm -rf .git" # clearing .git folder? without this stage had failure
 
  Create image:
    stage: build
    when: manual # run only manual, without automatic run after commits
    tags: 
       - build # tags for my local gitlab_runner
       
    script:
      - "rm -rf ~/${WORK_DIR}; mkdir -p ~/${WORK_DIR};  git init; git clone  ${REPO}; cd ${WORK_DIR}; docker build --rm -t ${NAME_IMGAGE}:${BUILD_VERSION} ."
      - "docker run --rm --name ${NAME_CONTAINER} -d -p80:80 -v /opt/jenkins_home:/var/jenkins_home  ${NAME_IMGAGE}:${BUILD_VERSION}"
  
  Test container:
    stage: test
    when: on_success  # run only if previos stage had success
    tags: 
      - test # tags for my local gitlab_runner
    script:
      - "mkdir -p /opt/jenkins_home/ ; sleep 20;  curl http://localhost | grep -o 'Welcome to Jenkins'"
      - "docker stop ${NAME_CONTAINER}"
  
  # push to docker hub
  Push:  
    stage: deploy
    when: on_success # run only if previos stage had success
    tags: 
      - deploy # tags for my local gitlab_runner
    script: 
      - "docker login -u ${GITHUB_USERNAME} -p ${GITHUB_PASSWORD}"
      - "docker push ${NAME_IMGAGE}:${BUILD_VERSION}"
```
## Build stage log
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic1.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic2.png  )

## Test stage log

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic3.png  )

## Push stage log 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic4.png  )

## Pipelines log
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic5.png  )

## Pipeline view

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic7.png  )

## On premises runner

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic6.png  )


## DockerHub

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task4-gitlab-pipeline1/screenshot/pic8.png  )

