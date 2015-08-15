Check nagios
============
Nagios
http://$nagios_server_ip:$nagios_server_port/nagios/
nagiosadmin/password1234

To check history of one check, here is an example:  telasticsearch mem utilization
http://$nagios_server_ip:$nagios_server_port/nagiosgraph/cgi-bin/show.cgi?host=oscaio&service=check_elasticsearch_mem
