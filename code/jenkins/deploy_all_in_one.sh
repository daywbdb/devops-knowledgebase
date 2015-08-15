#!/bin/bash -ex
##-------------------------------------------------------------------
## File : deploy_all_in_one.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-08-05>
## Updated: Time-stamp: <2015-08-14 16:56:17>
##-------------------------------------------------------------------

################################################################################################
## env variables: ssh_server_ip, ssh_port, project_name, chef_json, check_command,
##                kill_running_chef_update, devops_branch_name, env_parameters
## Example:
##       ssh_server_ip: 123.57.240.189
##       ssh_port: 6022
##       project_name: all-in-one-auth
##       chef_json:
##             {
##               "run_list": ["recipe[all-in-one-auth]"],
##               "os_basic_auth":{"repo_server":"123.57.240.189:28000"},
##               "all_in_one_auth":{"branch_name":"dev",
##               "install_audit":"1"}
##             }
##       check_command: enforce_all_nagios_check.sh "check_.*_log|check_.*_cpu"
##       kill_running_chef_update(boolean)
##       devops_branch_name: master
##       env_parameters:
##             export stop_container=false
##             export always_keep_instance=true
##             export stop_container=true
##             export kill_running_chef_update=false
##             export start_command="docker start osc-aio"
##             export stop_command="docker stop osc-aio"
################################################################################################
function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function shell_exit() {
    errcode=$?
    rm -rf $env_file
    if [ $errcode -eq 0 ]; then
        log "Action succeeds."
        if ! $always_keep_instance; then
            if [ -n "$stop_command" ]; then
                stop_instance_command="ssh -i $ssh_key_file -o StrictHostKeyChecking=no root@$ssh_server_ip $stop_command"
                log $stop_instance_command
                eval $stop_instance_command
            fi
        fi
    else
        log "Action Fails."
        if [ -n "$stop_container" ] && $stop_container; then
            if [ -n "$stop_command" ]; then
                stop_instance_command="ssh -i $ssh_key_file -o StrictHostKeyChecking=no root@$ssh_server_ip $stop_command"
                log $stop_instance_command
                eval $stop_instance_command
            fi
        fi
    fi
    exit $errcode
}

trap shell_exit SIGHUP SIGINT SIGTERM 0

########################################################################
log "env variables. kill_running_chef_update: $kill_running_chef_update, stop_container: $stop_container"

echo "Deploy to ${ssh_server_ip}:${ssh_port}"
env_dir="/tmp/env/"
env_file="$env_dir/$$"

if [ -n "$env_parameters" ]; then
    mkdir -p $env_dir
    log "env file: $env_file. Set env parameters: $env_parameters"
    cat > $env_file <<EOF
$env_parameters
EOF
    . $env_file
fi

working_dir="/root/"
ssh_key_file="/var/lib/jenkins/.ssh/id_rsa"
if [ -z "$git_repo_url" ]; then
    git_repo_url="git@bitbucket.org:authright/iamdevops.git"
fi
if [ -z "$code_sh"  ]; then
    code_sh="/root/iamdevops/misc/berk_update.sh"
fi
if [ -z "$code_dir" ]; then
    code_dir="/root/test"
fi

git_repo=$(echo ${git_repo_url%.git} | awk -F '/' '{print $2}')

start_instance_command="ssh -i $ssh_key_file -o StrictHostKeyChecking=no root@$ssh_server_ip $start_command"
if [ -n "$start_command" ]; then
    log $start_instance_command
    eval $start_instance_command
fi

if $kill_running_chef_update; then
    log "ps -ef | grep chef-solo || killall -9 chef-solo"
    ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip "killall -9 chef-solo || true"
fi

log "Update chef dependenies of berkshelf"
ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip $code_sh $code_dir $git_repo_url $git_repo $devops_branch_name $project_name

log "Prepare chef configuration"
echo "cookbook_path \"$code_dir/$devops_branch_name/$git_repo/cookbooks\"" > /tmp/client.rb
echo "$chef_json" > /tmp/client.json

scp -i $ssh_key_file -P $ssh_port -o StrictHostKeyChecking=no /tmp/client.rb root@$ssh_server_ip:/root/client.rb
scp -i $ssh_key_file -P $ssh_port -o StrictHostKeyChecking=no /tmp/client.json root@$ssh_server_ip:/root/client.json

log "Apply chef update"
ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip chef-solo --config /root/client.rb -j /root/client.json

if [ -n "$check_command" ]; then
    log "$check_command"
    ssh -i $ssh_key_file -p $ssh_port -o StrictHostKeyChecking=no root@$ssh_server_ip "$check_command"
fi

## File : deploy_all_in_one.sh ends
