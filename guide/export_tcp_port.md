Use ssh tunnel to access tcp port
=================================
```
Let's say we want to visit port 27017 for 50.198.76.253.

However this port is not opened by firewall, but ssh port(32823) is open

We can use ssh tunnel to map server's port 27017 to local port 27017.

Thus when we open http://localhost:27017 in local web browser, it would work like http://50.198.76.253:27017

ssh -N -p 32823 -f root@50.198.76.253 -L 27017:localhost:27017 -n /bin/bash
```
