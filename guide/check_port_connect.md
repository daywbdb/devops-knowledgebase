check tcp port connectivity issue
=================================

# connect from outside
telnet $server_ip $server_port

# connect from server inside
telnet 127.0.0.1 $server_port

# port listening
nc -l $server_port
