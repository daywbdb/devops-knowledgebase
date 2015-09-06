Access docker contianer
=======================

1. ssh to docker server
2. docker ps
```
ssh -p $ssh_port root@$docker_server
ssh -i /home/denny/denny root@192.168.1.185
docker ps
ssh -p $port root@127.0.0.1
```

Here is an example
```
root@docker-server:~# docker ps 
docker ps 
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                           NAMES
7ec7acbbe0c2        d09734308c83        "/usr/sbin/sshd -D -   About an hour ago   Up About an hour    0.0.0.0:34868->22/tcp                           tenantadmin-auth-jenkins-202   
f8267ad6e389        d09734308c83        "/usr/sbin/sshd -D -   About an hour ago   Up About an hour    0.0.0.0:34867->22/tcp                           all-in-one-auth-jenkins-146    
32f1167e7c53        d09734308c83        "/usr/sbin/sshd -D -   About an hour ago   Up About an hour    0.0.0.0:34866->22/tcp                           ssoportal-auth-jenkins-202     
1e298efd504f        73d30a030dde        "/usr/sbin/sshd -D -   4 weeks ago         Up 3 weeks          0.0.0.0:8080->8080/tcp, 0.0.0.0:32812->22/tcp   docker-regristry-important     
root@docker-server:~# ssh -p 34867 root@127.0.0.1
ssh -p 34867 root@127.0.0.1
The authenticity of host '[127.0.0.1]:34867 ([127.0.0.1]:34867)' can't be established.
ECDSA key fingerprint is 5e:87:d8:ac:b0:9d:ce:11:13:ad:7d:a8:1a:e4:36:6f.
Are you sure you want to continue connecting (yes/no)? yes
yes
Warning: Permanently added '[127.0.0.1]:34867' (ECDSA) to the list of known hosts.
root@f8267ad6e389:~#
```
