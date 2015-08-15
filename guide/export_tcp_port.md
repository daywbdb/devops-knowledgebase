Use ssh tunnel to access tcp port
=================================

Suppose the ssh port of server is 32823. We want to access port 27017, which is not allowed by firewall.

Use below command, we can open http://localhost:27017. It would work exactly like http://$server_ip:27017

ssh -N -p 32823 -f root@mdmlab -L 27017:localhost:27017 -n /bin/bash
