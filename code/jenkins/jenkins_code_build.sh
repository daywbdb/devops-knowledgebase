#!/bin/bash -e
##-------------------------------------------------------------------
## File : jenkins_code_build.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-07-03>
## Updated: Time-stamp: <2015-08-17 10:15:01>
##-------------------------------------------------------------------

################################################################################################
## env variables: working_dir, git_repo_url, branch_name, revision, files_to_copy, 
##                clean_start, force_build, build_command
## Example:
##      working_dir: /var/lib/jenkins/code
##      git_repo_url: git@bitbucket.org:authright/iam.git
##      branch_name: dev
##      branch_name: dev
##      revision: HEAD
##      files_to_copy: gateway/war/build/libs/gateway-war-1.0-SNAPSHOT.war oauth2/rest-service/build/libs/oauth2-rest-1.0-SNAPSHOT.war
##      env_parameters:
##           export clean_start=true
##           export force_build=false
##           export skip_copy=false
##      build_command: make
################################################################################################

function current_git_sha() {
    set -e
    local src_dir=${1?}
    cd $src_dir
    sha=$(git log -n 1 | grep commit | head -n 1 | awk -F' ' '{print $2}')
    echo $sha
}

function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function git_update_code() {
    set -e
    local git_repo=${1?}
    local git_repo_url=${2?}
    local branch_name=${3?}
    local working_dir=${4?}

    log "Git update code for '$git_repo_url' to $working_dir, branch_name: $branch_name"
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
    #git reset --hard
    git checkout $branch_name
    git pull
}

function generate_version() {
    local git_repo=${1?}
    local branch_name=${2?}
    local revision_sha=${3?}

    local my_ip=$(wget -qO- http://ipecho.net/plain)
    log "Build From $branch_name branch of $git_repo repo."
    log "Revision: $revision_sha"
    log "Build Time: `date +'%Y-%m-%d %H:%M:%S'`"
    log "Jenkins Job: ${JOB_NAME}:${BUILD_DISPLAY_NAME} on $my_ip"
}

function copy_to_reposerver() {
    # Upload Packages to local apache vhost
    local git_repo=${1?}
    shift
    local branch_name=${1?}
    shift
    local code_dir=${1?}
    shift
    local revision_sha=${1?}
    shift

    local files_to_copy=($*)
    cd $code_dir

    local repo_dir="/var/www/repo"
    local repo_link="$repo_dir/$branch_name"
    local dst_dir="$repo_dir/${branch_name}_code_${revision_sha}"

    [ -d $dst_dir ] || mkdir -p $dst_dir
    for f in ${files_to_copy[*]};do
        cp $f $dst_dir/
    done
    log "$(generate_version $git_repo $branch_name $revision_sha)" > $dst_dir/version.txt
    rm -rf $repo_link
    ln -s $dst_dir $repo_link

    log "Just keep $leave_old_count old builds for $repo_dir/$branch_name_code"
    ls -d -t $repo_dir/* | grep ${branch_name}_code | head -n $leave_old_count | xargs touch
    find $repo_dir -type d -name "${branch_name}_code*" -and -mtime +1 -exec rm -r {} +
}

flag_file="/var/lib/jenkins/$JOB_NAME.flag"

function shell_exit() {
    errcode=$?
    rm -rf $env_file
    if [ $errcode -eq 0 ]; then
        echo "OK"> $flag_file
    else
        echo "ERROR"> $flag_file
    fi
    exit $errcode
}

trap shell_exit SIGHUP SIGINT SIGTERM 0

. /etc/profile
########################################################################

leave_old_count=1 # only keep one days' build by default
# Build Repo
git_repo=$(echo ${git_repo_url%.git} | awk -F '/' '{print $2}')
code_dir=$working_dir/$branch_name/$git_repo
env_dir="/tmp/env/"
env_file="$env_dir/$$"

# evaulate env
if [ -n "$env_parameters" ]; then
    mkdir -p $env_dir
    log "env file: $env_file. Set env parameters: $env_parameters"
    cat > $env_file <<EOF
$env_parameters
EOF
    . $env_file
fi

log "env variables. clean_start: $clean_start, skip_copy: $skip_copy, force_build: $force_build, build_command: $build_command"
if [ -n "$clean_start" ] && $clean_start; then
    [ ! -d $code_dir ] || rm -rf $code_dir
fi

if [ ! -d $working_dir ]; then
    sudo mkdir -p "$working_dir"
    sudo chown -R jenkins:jenkins "$working_dir"
fi

if [ -d $code_dir ]; then
    old_sha=$(current_git_sha $code_dir)
else
    old_sha=""
fi

# Update code
git_update_code $git_repo $git_repo_url $branch_name $working_dir

new_sha=$(current_git_sha $code_dir)
log "old_sha: $old_sha, new_sha: $new_sha"
if ! $force_build; then
    if [ $revision = "HEAD" ] && [ "$old_sha" = "$new_sha" ]; then
        log "No new commit, since previous build"
        if [ -f $flag_file ] && [[ `cat $flag_file` = "ERROR" ]]; then
            log "Previous build has failed"
            exit 1
        else
            exit 0
        fi
    fi
fi

cd $code_dir
git checkout $revision

log "================= Build Environment ================="
env
log "\n\n\n"

log "================= Build Code ================="
log "================= cd $code_dir ================="
/usr/sbin/locale-gen --lang en_US.UTF-8
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

log "$build_command"
eval $build_command

if [ -n "$files_to_copy" ] && ! $skip_copy; then
    log "================= Generate Packages ================="
    copy_to_reposerver $git_repo $branch_name $code_dir $new_sha "$files_to_copy"
fi
## File : jenkins_code_build.sh ends
