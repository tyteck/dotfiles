#!/usr/bin/zsh
# this script will display one eod env url so I can easily click on it

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

export LOCAL_DOCKER_IP=$(docker network inspect bridge --format='{{index .IPAM.Config 0 "Gateway"}}')
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

alias elasticreset='artisan elasticsearch:delete && artisan elasticsearch:rebuild'
alias seedocs='artisan db:seed --class DocumentsSeeder && elasticreset'

#
#-------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------
#
function memorytests() {
    cd ${LUCIE_PATH}/laravel && artisan test --coverage-clover ./coverage.xml --exclude-group IgnoreCI --testsuite Memory --stop-on-failure
}

function refontebesoin() {
    cd ${LUCIE_PATH}/laravel && git checkout refonte-besoin && git pull
}

function mergerefontebesoin() {
    cd ${LUCIE_PATH}/laravel && git fetch -a && git merge origin/refonte-besoin
}

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
    if [[ -z $branchName ]]; then
        error 'rungGcloudTriggersWithBranch expects the branch name to be non empty'
        return 1
    fi

    local output=$(gcloud beta builds triggers list)
    local triggerName=''
    local triggerId=''
    echo $output | while read line; do
        local key=$(echo $line | cut -sd':' -f 1)
        local value=$(echo $line | cut -sd':' -f 2)
        # trimming
        value=${value// /}

        if [[ $key = 'name' ]]; then
            triggerName=${value}
        fi

        if [[ $key = 'id' ]]; then
            triggerId=${value}
        fi

        if [[ -z $key ]] && [[ -z $value ]]; then
            # it s a new trigger
            runTriggerWithGoodNameOnly "${triggerName}" "${triggerId}" "${branchName}"

            # then we reset trgger name and id
            triggerName=''
            triggerId=''
        fi
    done
    # we dont forget the last one
    runTriggerWithGoodNameOnly "${triggerName}" "${triggerId}" "${branchName}"
}

function runTriggerWithGoodNameOnly() {
    local triggerName=$1
    local triggerId=$2
    local branchName=$3
    if [[ ${triggerName} = 'k8s-jobs' ]] || [[ ${triggerName} = 'lucie-web-cloudrun' ]]; then
        cmd="gcloud beta builds triggers run ${triggerId} --branch ${branchName}"
        comment "running : {$cmd} for $triggerName"
        eval $cmd
    fi
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
