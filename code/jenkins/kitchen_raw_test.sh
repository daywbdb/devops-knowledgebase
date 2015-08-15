#!/bin/bash -e
##-------------------------------------------------------------------
## File : kitchen_raw_test.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-07-03>
## Updated: Time-stamp: <2015-08-08 16:06:52>
##-------------------------------------------------------------------

################################################################################################
## env variables: keep_instance, keep_failed_instance
## Example:
##      keep_instance(boolean)
##      keep_failed_instance(boolean)
################################################################################################
function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`"========== $msg ==========\n"
}

function shell_exit() {
    errcode=$?
    log "shell_exit: keep_failed_instance: $keep_failed_instance, keep_instance: $keep_instance"
    command="kitchen destroy || kitchen destroy || true"
    if [ $errcode -eq 0 ]; then
        log "Kitchen test pass."
    else
        log "Kitchen test fail."
    fi

    # whether destroy instance
    if [ -n "$keep_instance" ] && $keep_instance; then
        log "keep instance as demanded."
    else
        if [ $errcode -eq 0 ]; then
            log "Run $command" && eval "$command"
        else
            if ! $keep_failed_instance; then
                log "Run $command" && eval "$command"
            fi
        fi
    fi

    exit $errcode
}

trap shell_exit SIGHUP SIGINT SIGTERM 0

log "env variables. keep_instance: $keep_instance, keep_failed_instance: $keep_failed_instance"
command="rm -rf *.lock"
log "$command" && eval "$command"

command="kitchen destroy || true"
log "$command" && eval "$command"

command="kitchen create"
log "$command" && eval "$command"

command="kitchen converge"
log "$command" && eval "$command"

command="kitchen verify"
log "$command" && eval "$command"
## File : kitchen_raw_test.sh ends
