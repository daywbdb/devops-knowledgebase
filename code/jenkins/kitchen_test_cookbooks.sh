#!/bin/bash -e
##-------------------------------------------------------------------
## File : kitchen_test_cookbooks.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-07-03>
## Updated: Time-stamp: <2015-09-01 13:01:29>
##-------------------------------------------------------------------
################################################################################################
## env variables: git_repo_url, branch_name, working_dir, test_command,
##                cookbook_list, skip_cookbook_list, must_cookbook_list, env_parameters
## Example:
##      git_repo_url: git@bitbucket.org:authright/iamdevops.git 
##      branch_name: dev
##      working_dir: /var/lib/jenkins/code/dockerfeature
##      test_command: curl -L https://raw.githubusercontent.com/DennyZhang/data/master/jenkins/kitchen_raw_test.sh | bash
##      cookbook_list: gateway-auth oauth2-auth account-auth audit-auth mfa-auth message-auth platformportal-auth ssoportal-auth tenantadmin-auth
##      skip_cookbook_list: sandbox-test
##      must_cookbook_list: gateway-auth
##      env_parameters:
##         export keep_failed_instance=true
##         export keep_instance=false
##         export clean_start=false
################################################################################################

function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`"========== $msg ==========\n"
}

function git_update_code() {
    set -e
    local git_repo=${1?}
    local branch_name=${2?}
    local working_dir=${3?}
    local git_repo_url=${4?}
    local git_pull_outside=${5:-"no"}

    echo "Git update code for '$git_repo_url' to $working_dir, branch_name: $branch_name"
    # checkout code, if absent
    if [ ! -d $working_dir/$branch_name/$git_repo ]; then
        mkdir -p $working_dir/$branch_name
        cd $working_dir/$branch_name
        git clone --depth 1 $git_repo_url --branch $branch_name --single-branch
    else
        cd $working_dir/$branch_name/$git_repo
        git config remote.origin.url $git_repo_url
    fi

    cd $working_dir/$branch_name/$git_repo
    git checkout $branch_name
    git reset --hard
    git pull
}

function get_cookbooks() {
    cookbook_list=${1?}
    cookbook_dir=${2?}
    skip_cookbook_list=${3:-""}
    cd $cookbook_dir

    if [ "$cookbook_list" = "ALL" ]; then
        cookbooks=`ls -1 .`
        cookbooks="$cookbooks"
    else
        cookbooks=$(echo $cookbook_list | sed "s/,/ /g")
    fi

    # skip_cookbook_list
    cookbooks_ret=""
    for cookbook in $cookbooks; do
        if [[ "${skip_cookbook_list}" != *$cookbook* ]]; then
            cookbooks_ret="${cookbooks_ret}${cookbook} "
        fi
    done

    # must_cookbook_list
    if [ "$must_cookbook_list" = "ALL" ]; then
        must_cookbooks=`ls -1 .`
        must_cookbooks="$must_cookbooks"
    else
        must_cookbooks=$(echo $must_cookbook_list | sed "s/,/ /g")
    fi

    for cookbook in $must_cookbooks; do
        if [[ "${cookbooks_ret}" != *$cookbook* ]]; then
            cookbooks_ret="${cookbooks_ret}${cookbook} "
        fi
    done

    echo $cookbooks_ret | sed "s/ $//g"
}

function test_cookbook_list() {
    test_command=${1?}
    cookbooks=${2?}
    cookbook_dir=${3?}

    for cookbook in $cookbooks; do
        cd $cookbook_dir/$cookbook
        ################################################
        # configure kitchen file
        if [ -z "$KITCHEN_YAML" ]; then
            export KITCHEN_YAML=".kitchen.yml"
        fi
        if [ -z "$INSTANCE_NAME" ]; then
            export INSTANCE_NAME="${cookbook}-jenkins-${BUILD_ID}"
        fi

        export CURRENT_COOKBOOK=$cookbook
        ################################################

        log "test $cookbook"
        log "cd `pwd`"
        log "export INSTANCE_NAME=$INSTANCE_NAME"
        log "export KITCHEN_YAML=$KITCHEN_YAML"
        log "$test_command"

        if ! eval "$test_command"; then
            log "ERROR $cookbook"
            failed_cookbooks="${failed_cookbooks} ${cookbook}"
        fi
        unset INSTANCE_NAME
        log "failed_cookbooks=$failed_cookbooks"
    done
}

function shell_exit() {
    errcode=$?
    rm -rf $env_file
    exit $errcode
}
########################################################################
github_repo=$(echo ${git_repo_url%.git} | awk -F '/' '{print $2}')
env_dir="/tmp/env/"
env_file="$env_dir/$$"
code_dir=$working_dir/$branch_name/$github_repo

if [ -n "$env_parameters" ]; then
    mkdir -p $env_dir
    log "env file: $env_file. Set env parameters:"
    log "$env_parameters"
    cat > $env_file <<EOF
$env_parameters
EOF
    . $env_file
fi

if [ -n "$clean_start" ] && $clean_start; then
    [ ! -d $code_dir ] || sudo rm -rf $code_dir
fi

if [ ! -d $working_dir ]; then
    mkdir -p "$working_dir"
    chown -R jenkins:jenkins "$working_dir"
fi

git_update_code $github_repo $branch_name $working_dir $git_repo_url
cd $working_dir/$branch_name/$git_repo
git pull origin $branch_name

cookbook_dir="$code_dir/cookbooks"
cd $cookbook_dir

failed_cookbooks=""
cookbooks=$(get_cookbooks "$cookbook_list" "$cookbook_dir" "$skip_cookbook_list")

log "Get cookbooks List"
echo "cookbooks: $cookbooks"

echo "Set locale as en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

log "Test Cookbooks"
test_cookbook_list "$test_command" "$cookbooks" "$cookbook_dir"

if [ "$failed_cookbooks" != "" ]; then
    log "Failed cookbooks: $failed_cookbooks"
    exit 1
fi
## File : kitchen_test_cookbooks.sh ends
