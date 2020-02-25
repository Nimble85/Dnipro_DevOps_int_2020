# TASK - Ansible playbook
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic1.png  )

## Solution

Solution for task will bу realised in local enveronment virtualbox VM.
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic1_1.png  )

### As base application will be use "CRUD Sample: PHP, Bootstrap and MySQL" from GitHub     
https://github.com/medaimane/crud-php-pdo-bootstrap-mysql
```
Steps:
  1. Apply role lb_haproxy
     a. install haproxy 
     b. copy template config 
     c. start haproxy
     d. apply iptable rules
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
     2.12 apply iptable rules
  3. Apply role base_db
     3.1 Proconfiguring host 
     3.2 install  mariadb and dependecy
     3.3 run mariadb
     3.4 Copy database dump file
     3.5 Create database user with vault pass
     3.5 Restore database from user
     3.7 apply iptable rules
```
For run
## ansible-playbook main.yml --ask-vault-pass

results:
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic2.png  )

![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic3.png  )
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task5-ansible-v2/screenshot/pic3_3.png  )

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
    bind {{ hostvars['loadbalancer'].ansible_host }}:{{ port_ext_lb }}
    default_backend nginx_pool

backend nginx_pool
    balance     {{ balance_method }}
    mode http
    server  web1 {{ hostvars['web1'].ansible_host }}:{{ port_nginx_1 }} check
    server  web2 {{ hostvars['web1'].ansible_host }}:{{ port_nginx_2 }} check

## HTTPs section
listen https-proxy {{ hostvars['loadbalancer'].ansible_host }}:443
mode tcp
balance source
option httpclose
option forwardfor
server web1 {{ hostvars['web1'].ansible_host }}:443 check port 443
server web2 {{ hostvars['web2'].ansible_host }}:443 check port 443

```
### roles/lb_haproxy/tasks/main.yml
```
---
# tasks file for loadbalancer

- name: check linux distro
  debug: var=ansible_os_family

- name: prepare host before task
  include_task: prepare.yml

- name: Install dependensies and haproxy
  yum:
    name:
      - deltarpm
      - haproxy
    state: latest

- name: copy config haproxy
  template: src=haproxy.cfg.j2 dest={{ destin_haproxy_folder }}/haproxy.cfg owner=haproxy group=haproxy
  notify: reload haproxy


- name: start haproxy
  service:
    name: haproxy
    state: started
    enabled: yes

- name: apply iptables rules for loadbalancer
  include_task: iptables-rules-lb.yml
```
### roles/web_nginx/tasks/main.yml
```
---
# tasks file for web

- name: check linux distro
  debug: var=ansible_os_family

- name: prepare host before task
  include_task: prepare.yml
  
- name: Install Nginx
  yum:
    name:
      - nginx
    state: latest
    
- name: install php and dependency
  include_task: install-php-dep.yml

- name: create folder /var/www/project.local
  file:
    path: /var/www/project.local
    state: directory
    owner: nginx
    group: nginx
    mode : '0644'

- name: add domain project.local and ssl.progect,local to host file
  blockinfile:
    path: /etc/hosts
    block: |
      127.0.0.1  project.local
      127.0.0.1  ssl.project.local

- name: copy  mysite  
  copy: src=site/ dest=/var/www/project.local/  owner=nginx group=nginx
  notify: reload nginx

- name: copy temlate config php site Vault pass for connect to base
  template: src=dbconfig.php.j2 dest=/var/www/project.local/dbconfig.php owner=nginx group=nginx
  notify: reload nginx
   
- name: copy confi===g nginx
  copy: src=nginx.conf dest={{ destin_nginx_folder }}/nginx.conf  owner=nginx group=nginx
  notify: reload nginx  

#### ssl #######
- name: create folder for ssl
  file:
    path: /etc/ssl/private
    state: directory
    mode: '0700'
- name: copy selfsigned key to /etc/ssl/private
  copy: src=ssl/nginx-selfsigned.key dest=/etc/ssl/private/nginx-selfsigned.key
  notify: reload nginx

- name: copy dhparam.pem to /etc/ssl/certs/
  copy: src=ssl/dhparam.pem  dest=/etc/ssl/certs/dhparam.pem
  notify: reload nginx

- name: copy nginx-selfsigned.crt to /etc/ssl/certs/
  copy: src=ssl/nginx-selfsigned.crt dest=/etc/ssl/certs/nginx-selfsigned.crt
  notify: reload nginx
##### end ssl ####

########### configure php.ini php-fpm  ################

- name: copy template config php-fpm
  template: src=www.conf.j2 dest=/etc/php-fpm.d/www.conf

- name: confguring php.ini
  lineinfile:
    path: /etc/php.ini
    line: cgi.fix_pathinfo=0

############ end php.ini php-fpm  #################

- name: start php-fpm
  service:
      name   : php-fpm
      state  : started
      enabled: yes

- name: start nginx
  service:
      name   : nginx
      state  : started
      enabled: yes

- name: test services
  command: systemctl status {{ item }}
  with_items:
    - php-fpm
  register: service_status_php_fpm
- debug: 
    var: service_status_php_fpm 

- name: test services
  command: systemctl status {{ item }}
  with_items:
    - nginx
  register: service_status_nginx
- debug: 
    var: service_status_nginx

- name: check sock
  shell: ls -l /var/run/php-fpm/php-fpm.sock 
  register: sock_info
- debug:
    var: sock_info

- name: check services open ports
  shell: netstat -tlpn
  register: netstat_result

- debug:
    var: netstat_result
 
- name: apply iptables rules for webservers
  include_task: iptables-rules-web.yml
 ```

### roles/base_db/tasks/main.yml
``` 
---
# tasks file for base_db
- name: check linux distro
  debug: var=ansible_os_family

- name: prepare host before task
  include_task: prepare.yml

- name: install mariadb and dependecy
  yum:
    name:
      - mariadb 
      - mariadb-server 
      - net-tools
 
    state: latest

- name: install Python and dependensy
  include_task: install-py-depend.yml

- name: start mariadb
  service:
    name   : mariadb
    state  : started
    enabled: yes

- name: Copy database dump file
  copy:
    src : sql/dbpdo.sql
    dest: /tmp

- name: Create a new database
  mysql_db:
    name  : "{{ dbname }}"
    state : present
    
- name: Create database user  with name 'dppdo@'%'' and VAULT password  with all database privileges
  mysql_user:
    name    : "{{ dbuser }}"
    host    : "%"
    password: "{{ dbpass }}"
    priv    : '{{ dbname }}.*:ALL'
    state   : present
  
- name: Create database user  with name 'dppdo@localhost' and VAULT password  with all database privileges
  mysql_user:
    name    : "{{ dbuser }}"
    password: "{{ dbpass }}"
    priv    : '{{ dbname }}.*:ALL'
    state   : present
    
- name: Restore database from user dppdo@'%
  mysql_db:
    login_user    : "{{ dbuser }}"
    login_password: "{{ dbpass }}"
    name          : "{{ dbname }}"
    state         : import
    target        : /tmp/dbpdo.sql

- name: apply iptables rules for base_db
  include_task: iptables-rules-db.yml
```


# roles/web_nginx/tasks/iptable-rules-web.yml
```
---
- iptables_raw:
  name: rules
    rules: |
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
      -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
      -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A OUTPUT -p tcp -j ACCEPT
      
- name: save iptables
  command: iptables-save
```

