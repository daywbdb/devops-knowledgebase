ssh without password
====================
1. When ssh to server, username/password is insecure. env would be vulnerable to brute force login.
2. If members leaving the team, we will have to reset OS password.

This is quite painful.

One way out is enforcing ssh by key file.

Upload your ssh key file, so that when you ssh to server, you won't be asked to input password.
```
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAwp69ZIA8Usz5EgSh5gBXKGFZBUawP8nDSgZVW6Vl/+NDhij5Eo5BePYvUaxg/5aFxrxROOyLGE9xhNBk7PP49Iz1pqO9T/QNSIiuuvQ/Xhpvb4OQfD5xr6l4t/9gLf+OYGvaFHf/xzMnc9cKzZ+azLlDHbeewu1GMI/XNFWo4VWAsH+6xM8VIpdJSaR7alJn/W6dmyRBbk0uS3Yut63jVFk4zalAzXquU0BX1ne+DLB/LW8ZanN5PWECabSi4dXYLfxC2rDhDcQdXU3MwV5b7TtR5rFoNS8IGcyHoeq5tasAtAAaD2sEzyJbllAfFsNyxNQ+Yh8935HcWqx2/T0r filebat.mark@gmail.com" >> ~/.ssh/authorized_keys
```
