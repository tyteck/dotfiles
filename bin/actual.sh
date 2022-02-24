#!/usr/bin/zsh
# this script will display one eod env url so I can easily click on it

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

function eodurl() {
    if [ -z $EOD_PASSWORD ]; then
        error "EOD_PASSWORD is empty. You should export it somewhere"
        error "IE : export EOD_PASSWORD=<PASSWORD>"
        return 1
    fi

    local branchName=$1
    if [ -z $branchName ]; then
        warning "Usage : eodurl <BRANCH_NAME> (ie : eodurl T1-684-jobboard-email)"
        return 1
    fi

    echo "https://actual:${EOD_PASSWORD}@${branchName}.eod.groupeactual.io/lucie"
}

function pushluciepp() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning "Usage : pushluciepp <BRANCH_NAME> (ie : pushluciepp s21-17)"
        return 1
    fi

    gcloud config set project eactual-preprod

    rungGcloudTriggersWithBranch $branchName
}

function pushninadev() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning "Usage : pushninadev <BRANCH_NAME> (ie : pushninadev develop)"
        return 1
    fi

    gcloud config set project synchro-rh-dev

    rungGcloudTriggersWithBranch $branchName
}

function rungGcloudTriggersWithBranch() {
    local branchName=$1
    if [ -z $branchName ]; then
        error "rungGcloudTriggersWithBranch expects the branch name to be non empty"
        return 1
    fi

    local output=$(gcloud beta builds triggers list)
    echo $output | while read line; do

        key=$(echo $line | cut -sd':' -f 1)
        value=$(echo $line | cut -sd':' -f 2)
        # trimming
        value=${value// /}
        if [ -z $key ]; then
            # we are on a separator string '---'
            continue
        fi

        if [ $key = 'id' ]; then
            cmd="gcloud beta builds triggers run ${value} --branch ${branchName}"
            comment "running : $cmd"
            eval $cmd
        fi
    done
}
