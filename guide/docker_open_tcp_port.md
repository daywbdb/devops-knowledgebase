Docker open tcp to access from outside
======================================
- At the staging of docker container creation, we can use "-p" to do port forwarding.

In Below command, port 10001 of docker daemon server is mapping to docker container's 10001.

docker run -t -d --privileged -h aio --name docker-all-in-one -p 10001:10001 -p 80:80 -p 1389:1389 -p 6022:22 denny/osc:latest /usr/sbin/sshd -D

So if port 10001 of docker daemon is accessible from outside, so is docker container's 10001 port.

- When docker container is already started and we want to export more tcp port to outside, we have to use iptables.

First we find out ip of docker container. Let's say it's 172.17.0.19.

Run below command to mapping docker daemon's 10001 port to container's 172.17.0.19.
sudo iptables -t nat -A DOCKER -p tcp --dport 10001 -j DNAT --to-destination 172.17.0.19:10001

To verify iptables rules, run below
sudo iptables -t nat -L -n

```
Note: whenever docker container is restarted, its ip address will be changed.
If we're using method #2, we will have to remove old iptables rules and add new one manually.

For method #1, we don't need to do anything for container restart.
```
