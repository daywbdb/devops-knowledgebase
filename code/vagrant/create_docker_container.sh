#!/bin/bash -e
##-------------------------------------------------------------------
## File : create_docker_container.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-08-16>
## Updated: Time-stamp: <2015-08-16 20:08:08>
##-------------------------------------------------------------------
docker run -t -d --privileged --name docker-jenkins -p 4022:22 -p 28000:28000 -p 3128:3128 -p 28080:28080 denny/osc:latest /usr/sbin/sshd -D
docker run -t -d --privileged --name docker-aio -h oscaio -p 10000-10050:10000-10050 -p 1389:1389 -p 27017:27017 -p 80:80 -p 6022:22 denny/osc:latest /usr/sbin/sshd -D
# Start service inside jenkins
docker exec docker-jenkins service jenkins start
docker exec docker-jenkins service apache2 start
## File : create_docker_container.sh ends
