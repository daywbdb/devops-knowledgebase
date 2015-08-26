#!/bin/bash -ex
##-------------------------------------------------------------------
## File : test_docker_reboot.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-08-05>
## Updated: Time-stamp: <2015-08-26 08:29:08>
##-------------------------------------------------------------------

################################################################################################
## env variables: start_instance_command, stop_instance_command, check_instance_command, stop_after_test
##
## Example:
##       start_instance_command: ssh root@192.168.1.185 docker start osc-aio
##       stop_instance_command: ssh root@192.168.1.185 docker stop osc-aio
##       check_instance_command: ssh -p 6022 root@192.168.1.185 enforce_all_nagios_check.sh "check_.*_log|check_.*_cpu"
##       stop_after_test (boolean)
################################################################################################
function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function shell_exit() {
    errcode=$?
    if [ $errcode -eq 0 ]; then
        log "Action succeeds."
    else
        log "Action Fails."
    fi

    if $stop_after_test; then
        log $stop_instance_command
        $stop_instance_command
    fi
    exit $errcode
}

trap shell_exit SIGHUP SIGINT SIGTERM 0

########################################################################
log "$start_instance_command"
$start_instance_command
sleep 5

log "$check_instance_command"
$check_instance_command
## File : test_docker_reboot.sh ends
