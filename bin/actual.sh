#!/usr/bin/zsh
# this script will display one eod env url so I can easily click on it

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

export LOCAL_DOCKER_IP=$(docker network inspect bridge --format='{{index .IPAM.Config 0 "Gateway"}}')
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export SOGEDEP_PATH="$PROJECTS_PATH/github.com/sogedep-om"
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

alias elasticreset='artisan elasticsearch:delete && artisan elasticsearch:rebuild'
alias seedocs='artisan db:seed --class DocumentsSeeder && elasticreset'

#
#-------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------
#

function eodurl() {
    if [ -z $EOD_PASSWORD ]; then
        error 'EOD_PASSWORD is empty. You should export it somewhere'
        error 'IE : export EOD_PASSWORD=<PASSWORD>'
        return 1
    fi

    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : eodurl <BRANCH_NAME> (ie : eodurl T1-684-jobboard-email)'
        return 1
    fi

    echo "https://actual:${EOD_PASSWORD}@${branchName}.eod.groupeactual.io/lucie"
}

function pushluciepp() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushluciepp <BRANCH_NAME> (ie : pushluciepp s21-17)'
        return 1
    fi

    gcloud config set project eactual-preprod

    rungGcloudTriggersWithBranch $branchName
}

function pushninadev() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushninadev <BRANCH_NAME> (ie : pushninadev develop)'
        return 1
    fi

    gcloud config set project synchro-rh-dev

    rungGcloudTriggersWithBranch $branchName
}

function pushluciedev() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushluciedev <BRANCH_NAME> (ie : pushluciedev s21-17)'
        return 1
    fi

    gcloud config set project eactual-215607

    rungGcloudTriggersWithBranch $branchName
}

function rungGcloudTriggersWithBranch() {
    local branchName=$1
    if [ -z $branchName ]; then
        error 'rungGcloudTriggersWithBranch expects the branch name to be non empty'
        return 1
    fi

    local output=$(gcloud beta builds triggers list)
    echo $output | while read line; do
        key=$(echo $line | cut -sd':' -f 1)
        value=$(echo $line | cut -sd':' -f 2)
        # trimming
        value=${value// /}
        #echo "key : |${key}| --- value : ${value}"
        if [ -z $key ]; then
            continue
        fi

        if [ $key = 'id' ]; then
            cmd="gcloud beta builds triggers run ${value} --branch ${branchName}"
            comment "running : $cmd"
            eval $cmd
        fi
    done
}

function luciedown() {
    eval ${LUCIE_COMPOSE} down --remove-orphans
}

function lucieup() {
    persodown
    sogedown
    docker network inspect actual-network >/dev/null 2>&1
    if [ $? != 0 ]; then
        docker network create actual-network
    fi
    eval ${LUCIE_COMPOSE} up -d
    cd ${LUCIE_PATH}/laravel
}

function lucierestart() {
    luciedown
    lucieup
}

function ninadown() {
    eval ${NINA_COMPOSE} down --remove-orphans
}

function ninaup() {
    persodown
    eval ${NINA_COMPOSE} up -d
    cd ${NINA_PATH}
}

function actualdown() {
    comment "=====> actual =====> DOWN"
    ninadown
    luciedown
}

function persoup() {
    comment "=====> perso =====> UP"
    actualdown

    docker network inspect nginx-proxy >/dev/null 2>&1
    if [ $? != 0 ]; then
        docker network create nginx-proxy
    fi
    nginxup
    mysqlup
    phpmyadminup
    mailup
}

function domup() {
    comment "=====> dom =====> UP"
    actualdown
    persodown
    cd {$PROJECTS_PATH}/github.com/sogedep-om
    docker compose up -d
}
