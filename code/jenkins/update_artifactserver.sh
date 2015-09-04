#!/bin/bash -ex
##-------------------------------------------------------------------
## File : update_artifactserver.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-08-05>
## Updated: Time-stamp: <2015-09-04 13:45:55>
##-------------------------------------------------------------------

################################################################################################
## env variables: ssh_server_ip, env_parameters
##
## Example:
##       ssh_server_ip: 123.57.240.189
##       env_parameters:
##             export ssh_port=22
##             export ssh_key_file="/var/lib/jenkins/.ssh/id_rsa"
##             export src_dir=/var/www/repo/dev
##             export dst_dir=/var/www/repo/dev
################################################################################################
function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

########################################################################

env_dir="/tmp/env/"
env_file="$env_dir/$$"

if [ -n "$env_parameters" ]; then
    mkdir -p $env_dir
    log "env file: $env_file. Set env parameters:"
    log "$env_parameters"
    cat > $env_file <<EOF
$env_parameters
EOF
    . $env_file
fi

log "env variables. kill_running_chef_update: $kill_running_chef_update, stop_container: $stop_container"

# ssh_server_ip
tmp_dir="/root/artifact/"

if [ -z "$src_dir" ]; then
    src_dir="/var/www/repo/dev"
fi

if [ -z "$dst_dir" ]; then
    dst_dir="/var/www/repo/dev"
fi

if [ -z "$ssh_key_file" ]; then
    ssh_key_file="/var/lib/jenkins/.ssh/id_rsa"
fi

if [ -z "$ssh_port" ]; then
    ssh_port="22"
fi

ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip mkdir -p $tmp_dir

log "scp files from local machine to $ssh_server_ip"
scp -i $ssh_key_file -P $ssh_port -o StrictHostKeyChecking=no -r $src_dir/* root@$ssh_server_ip:/$tmp_dir/

log "make symbol link"
ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip rm -rf $dst_dir
ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip ln -s $tmp_dir $dst_dir

## File : update_artifactserver.sh ends
