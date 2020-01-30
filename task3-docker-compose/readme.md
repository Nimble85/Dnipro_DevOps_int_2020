# Task 3
1.	Создать файл Docker-compose, который развернет данное окружение:
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task3-docker-compose/screenshot/pic1.png  )
2.	Вывести простое описание хостовой машины на стартовой страничке.
3.	Сделать доступное описание в файле README.MD
4.	Проект залить на https://github.com/

# Solution

## docker-compose.yml
version: "3"    
services:    
    nginx:    
        image: nginx:1.13    
        ports:    
          - "80"    
        restart: always    
        expose:    
          - 8081    
        volumes:    
          - ./nginx:/usr/share/nginx/html    
        networks:    
          - back-tier    
    apache:    
        image: httpd:2.4   
        restart: always    
        expose:    
          - 8082    
        volumes:   
          - ./apache:/usr/local/apache2/htdocs    
        networks:   
          - back-tier   
    lb:    
        image: dockercloud/haproxy   
        links:   
          - nginx    
          - apache   
        ports:    
          - "80:80"    
        restart: always   
        networks:    
          - front-tier    
          - back-tier    
        volumes:    
          - /var/run/docker.sock:/var/run/docker.sock    
networks:     
    front-tier:     
        driver: bridge    
    back-tier:   
        driver: bridge     

## Create dirs for html files apache and nginx containers
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task3-docker-compose/screenshot/pic6.png  )

### run command 
# docker-compose up
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task3-docker-compose/screenshot/pic5.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task3-docker-compose/screenshot/pic4.png  )

# In conclusion we have  results
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task3-docker-compose/screenshot/pic3.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task3-docker-compose/screenshot/pic2.png  )



