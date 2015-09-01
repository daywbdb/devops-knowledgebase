ssh without password
====================
1. When ssh to server, username/password is insecure. env would be vulnerable to brute force login.
2. If members leaving the team, we will have to reset OS password.

This is quite painful.

One way out is enforcing ssh by key file.

Upload your ssh key file, so that when you ssh to server, you won't be asked to input password.
```
echo "ssh-rsa AAAAB3NzaC1yc2EA...+Yh8935HcWqx2/T0r filebat.mark@gmail.com" >> ~/.ssh/authorized_keys
```
