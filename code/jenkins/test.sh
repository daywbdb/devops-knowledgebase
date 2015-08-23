#!/bin/bash -ex

function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`"========== $msg ==========\n"
}

function shell_exit() {
    errcode=$?
    log "shell_exit: keep_failed_instance: $keep_failed_instance, keep_instance: $keep_instance"
    command="echo shell_exit"
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

command="false"
log "$command" && eval "$command"

command="true"
log "$command" && eval "$command"
