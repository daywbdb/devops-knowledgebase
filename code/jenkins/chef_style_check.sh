#!/bin/bash -e
##-------------------------------------------------------------------
## File : chef_style_check.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-07-03>
## Updated: Time-stamp: <2015-08-08 16:06:46>
##-------------------------------------------------------------------
function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

# get default env parameter
if [ -z "$CURRENT_COOKBOOK" ]; then
    export COOKBOOK="../"$(basename $(pwd))
else
    export COOKBOOK="../$CURRENT_COOKBOOK"
fi

log "foodcritic $COOKBOOK"
foodcritic $COOKBOOK

log "rubocop $COOKBOOK"
rubocop $COOKBOOK
## File : chef_style_check.sh ends
