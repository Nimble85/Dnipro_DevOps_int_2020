# TASK - Ansible playbook
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic1.png  )

## Solution

Solution for task will bу realisen in local enveronment virtualbox VM.
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic1_1.png  )

### As base application wil be use "CRUD Sample: PHP, Bootstrap and MySQL" from GitHub     
https://github.com/medaimane/crud-php-pdo-bootstrap-mysql
```
Steps:
  1. Apply role lb_haproxy
     a. install haproxy 
     b. copy template config 
  2. Apply role web_nginx
     2.1  Proconfiguring host (disablr selinux, turn on ip forward)
     2.2 install nginx, php-fpm, php and dependensy
     2.3 create folder for site 
     2.4 copy site 
     2.5 copy template dbconfig.php.j2 with vault pass
     2.6 copy nginx.conf with php and ssl config
     2.7 configuring php.ini
     2.8 create dir and copy ssl sefsigned sert
     2.9 Replace string mfp conf 
     2.10 start php-fpm nginx
     2.11 test runing sevices
  3. Apply role base_db
     3.1 Proconfiguring host 
     3.2 install  mariadb and dependecy
     3.3 run mariadb
     3.4 Copy database dump file
     3.5 Restore database
     3.6 Create database user with vault pass
```
For run
## ansible-playbook main.yml --ask-vault-pass

results:
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic2.png  )

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic3.png  )

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic4.png  )


Review key-files:
### haproxy.cfg.j2 

```
global
  //////
   skip
  /////
defaults
  ////////
  skip
  ////////
frontend  www
    bind {{ ip_ext_lb }}:{{ port_ext_lb }}
    default_backend nginx_pool

backend nginx_pool
    balance     {{ balance_method }}
    mode http
    server  web1 {{ ip_nginx_1 }}:{{ port_nginx_1 }} check
    server  web2 {{ ip_nginx_2 }}:{{ port_nginx_2 }} check

```
### roles/lb_haproxy/tasks/main.yml
```
---
# tasks file for loadbalancer

- name: ping servers
  ping:

- name: check linux distro
  debug: var=ansible_os_family

- name: iptables flush filter
  iptables:
    chain: "{{ item }}"
    flush: yes
  with_items:  [ 'INPUT', 'FORWARD', 'OUTPUT' ]

- name: save rules iptables
  shell: /sbin/iptables-save  > /etc/sysconfig/iptables

- sysctl:
    name: net.ipv4.ip_forward
    value: '1'
    sysctl_set: yes
    state: present
    reload: yes

- name: Ensure SELinux is set to disabled mode
  lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: SELINUX=disabled

- name: apply turn off selinux without reboot
  shell: setenforce 0

- name: Install dependensies and haproxy
  yum:
    name:
      - deltarpm
      - haproxy
    state: latest

- name: copy config haproxy
  template: src=haproxy.cfg.j2 dest={{ destin_haproxy_folder }}/haproxy.cfg owner=haproxy group=haproxy
  notify: restart haproxy

- name: start haproxy
  service:
    name: haproxy
    state: started
    enabled: yes
```
### roles/web_nginx/tasks/main.yml
```
---
# tasks file for web
- name: ping servers
  ping:

- name: check linux distro
  debug: var=ansible_os_family

#- name: update all packages
#  yum:
#    name: '*'
#    state: latest
- name: iptables flush filter
  iptables:
    chain: "{{ item }}"
    flush: yes
  with_items:  [ 'INPUT', 'FORWARD', 'OUTPUT' ]

- name: save rules iptables
  shell: /sbin/iptables-save  > /etc/sysconfig/iptables

- sysctl:
    name: net.ipv4.ip_forward
    value: '1'
    sysctl_set: yes
    state: present
    reload: yes

- name: Ensure SELinux is set to disabled mode
  lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: SELINUX=disabled

- name: apply turn off selinux without reboot
  shell: setenforce 0
  
- name: Install Nginx
  yum:
    name:
      - nginx
      - php-fpm 
      - php-common
      - php
      - php-cli 
      - php-mysql 
    state: latest

- name: create folder /var/www/project.local
  file:
    path: /var/www/project.local
    state: directory
    owner: nginx
    group: nginx
    mode : '0777'

- name: create log file for site
  file:
    path: /var/log/nginx/project.local-access.log  
    state: touch
    name : nginx
    group: nginx

- name: create err log file for site
  file:
    path : /var/log/nginx/project.local-error.log
    state: touch
    name : nginx
    group: nginx

- name: add domain project.local and ssl.progect,local to host file
  blockinfile:
    path: /etc/hosts
    block: |
      127.0.0.1  project.local
      127.0.0.1  ssl.project.local

- name: copy  mysite  
  copy: src=site/ dest=/var/www/project.local/  owner=nginx group=nginx
  notify: restart nginx

- name: copy temlate config php site Vault pass for connect to base
  template: src=dbconfig.php.j2 dest=/var/www/project.local/dbconfig.php owner=nginx group=nginx
  notify: restart nginx
   
- name: copy confi===g nginx
  copy: src=nginx.conf dest={{ destin_nginx_folder }}/nginx.conf  owner=nginx group=nginx
  notify: restart nginx  

#### ssl #######
- name: create folder for ssl
  file:
    path: /etc/ssl/private
    state: directory
    mode: '0700'
- name: copy selfsigned key to /etc/ssl/private
  copy: src=ssl/nginx-selfsigned.key dest=/etc/ssl/private/nginx-selfsigned.key
  notify: restart nginx

- name: copy dhparam.pem to /etc/ssl/certs/
  copy: src=ssl/dhparam.pem  dest=/etc/ssl/certs/dhparam.pem
  notify: restart nginx

- name: copy nginx-selfsigned.crt to /etc/ssl/certs/
  copy: src=ssl/nginx-selfsigned.crt dest=/etc/ssl/certs/nginx-selfsigned.crt
  notify: restart nginx
##### end ssl ####

########### configure php-fpm  ################
- name: conure confguring php.ini
  lineinfile:
    path: /etc/php.ini
    line: cgi.fix_pathinfo=0

- name: Replace listen  string mfp conf
  lineinfile:
    path  : /etc/php-fpm.d/www.conf
    regexp: '^listen = 127\.0\.0\.1'
    line  : ;listen = 127.0.0.1:9000
  notify: restart php-fpm

- name: add string in www.comf
  blockinfile:
    path: /etc/php-fpm.d/www.conf
    block: |
      listen = /var/run/php-fpm/php-fpm.sock
      listen.mode = 0660
      listen.owner = nginx
      listen.group = nginx
  notify: restart php-fpm

- name: Replace a apache user to nginx
  lineinfile:
    path  :  /etc/php-fpm.d/www.conf
    regexp: '^user = '
    line  : user = nginx
  notify: restart php-fpm

- name: Replace a apache group to nginx
  lineinfile:
    path  :  /etc/php-fpm.d/www.conf
    regexp: '^group = '
    line  : group = nginx
  notify: restart php-fpm
############ end php-fpm  #################

- name: start php-fpm
  service:
      name: php-fpm
      state: started
      enabled: yes

- name: start nginx
  service:
      name: nginx
      state: started
      enabled: yes

- name: test services
  command: systemctl status {{ item }}
  with_items:
    - php-fpm
    - nginx
  register: service_status

- debug: 
    var: service_status

#- name: check sock
#  shell: ls -l /var/run/php-fpm/php-fpm.sock 
#  register: sock_info
#- debug:
#    var: sock_info

- name: check services open ports
  shell: netstat -tlpn
  register: netstat_result

- debug:
    var: netstat_result
 ```

### roles/base_db/tasks/main.yml
``` 
---
# tasks file for base_db
- name: ping servers
  ping:

- name: check linux distro
  debug: var=ansible_os_family

#- name: update all packages
#  yum:
#    name: '*'
#    state: latest

- name: iptables flush filter
  iptables:
    chain: "{{ item }}"
    flush: yes
  with_items:  [ 'INPUT', 'FORWARD', 'OUTPUT' ]

- name: save rules iptables
  shell: /sbin/iptables-save  > /etc/sysconfig/iptables

- name: Ensure SELinux is set to disabled mode
  lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: SELINUX=disabled

- name: apply turn off selinux without reboot
  shell: setenforce 0

- name: install mariadb and dependecy
  yum:
    name:
      - mariadb 
      - mariadb-server 
      - net-tools
      - python
      - python-pip
      - MySQL-python
    state: latest

- name: pip upgrade
  shell: pip install --upgrade pip

- name: disable strict sql
  blockinfile:
    path: /etc/mysql/conf.d/disable_strict_mode.cnf
    block: |
      [mysqld]
      sql_mode=IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
    create: yes
  notify: restart mariadb

- name: start mariadb
  service:
    name: mariadb
    state: started
    enabled: yes

- name: Copy database dump file
  copy:
    src: sql/dbpdo.sql
    dest: /tmp

- name: Restore database
  mysql_db:
    name: "{{ dbname }}"
    state: import
    target: /tmp/dbpdo.sql

- name: Create database user  with name 'dppdo@'%'' and VAULT password  with all database privileges
  mysql_user:
    name: "{{ dbuser }}"
    host: "%"
    password: "{{ dbpass }}"
    priv: '*.*:ALL'
    state: present

- name: Create database user  with name 'dppdo@localhost' and VAULT password  with all database privileges
  mysql_user:
    name: "{{ dbuser }}"
    password: "{{ dbpass }}"
    priv: '*.*:ALL'
    state: present