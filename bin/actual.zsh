#!/usr/bin/zsh

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

export LOCAL_DOCKER_IP=$(docker network inspect bridge --format='{{index .IPAM.Config 0 "Gateway"}}')
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

alias elasticreset='artisan elasticsearch:delete && artisan elasticsearch:rebuild'
alias seedocs='artisan db:seed --class DocumentsSeeder && elasticreset'
alias fredseeder='artisan db:seed --class FredSeeder'

#
#-------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------
#
function rebuildTestingIfNeeded() {
    dblucielocal -e "create database if not exists actual_testing;" >/dev/null 2>&1
    comment "actual_testing ✅"
}

function tests() {
    if inLucie; then
        rebuildTestingIfNeeded
    fi

    local executablePath='vendor/bin/phpunit'

    if ! dockerFileExists $executablePath; then
        error "There is no ${executablePath} by there."
        return 1
    fi

    # get the command to access container
    local dockerPrefix=$(getDockerPrefix)
    local commandToRun="${dockerPrefix}${executablePath} $@"
    comment $commandToRun
    eval $commandToRun
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

    echo "https://actual:${EOD_PASSWORD}@${branchName}.eodv2.groupeactual.io/lucie"
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

    triggersToRun="k8s-jobs lucie-web-cloudrun"
    rungGcloudTriggersWithBranch $branchName $triggersToRun
}

function pushlucieeod() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushluciedeod <BRANCH_NAME> (ie : pushluciedev s21-17)'
        return 1
    fi

    gcloud config set project eactual-215607
    triggersToRun="k8s-jobs-ondemand-manuel"
    rungGcloudTriggersWithBranch $branchName $triggersToRun
}

function rungGcloudTriggersWithBranch() {
    local branchName=$1
    if [[ -z $branchName ]]; then
        error 'rungGcloudTriggersWithBranch expects the branch name to be non empty'
        return 1
    fi

    local triggerNamesToRun=$2
    if [[ -z $triggerNamesToRun ]]; then
        error 'rungGcloudTriggersWithBranch expects the triggers to run non being empty'
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

        # it s a new line => new item to come
        # let s process the one we finished
        if [[ -z $key ]] && [[ -z $value ]] && in_array $triggerName $triggerNamesToRun; then
            # it s a trigger to run
            runTriggerWithGoodNameOnly "${triggerName}" "${triggerId}" "${branchName}"

            # then we reset trigger name and id
            triggerName=''
            triggerId=''
        fi
    done
    if in_array $triggerName $triggerNamesToRun; then
        # we dont forget the last line
        runTriggerWithGoodNameOnly "${triggerName}" "${triggerId}" "${branchName}"
    fi
}

function runTriggerWithGoodNameOnly() {
    local triggerName=$1
    local triggerId=$2
    local branchName=$3
    cmd="gcloud beta builds triggers run ${triggerId} --branch ${branchName}"
    comment "running : {$cmd} for $triggerName"
    eval $cmd
}

function luciedown() {
    eval ${LUCIE_COMPOSE} down --remove-orphans
}

function lucieup() {
    persodown
    sogedown
    ninadown
    docker network inspect actual-network >/dev/null 2>&1
    if [ $? != 0 ]; then
        docker network create actual-network
    fi
    logFile=${LUCIE_PATH}/laravel/storage/logs/laravel-$(date "+%Y-%m-%d").log
    touch $logFile && sudo chown www-data:fred $logFile
    eval ${LUCIE_COMPOSE} up -d
    cd ${LUCIE_PATH}/laravel
}

function lucierestart() {
    luciedown
    lucieup
}

function ninastart() {
    eval ${NINA_COMPOSE} run --rm -p 127.0.0.1:3000:3000 node pnpm start
}

function ninadown() {
    echo ${NINA_COMPOSE} down --remove-orphans
    eval ${NINA_COMPOSE} down --remove-orphans
}

function dacup() {
    persodown
    cd ${DAC_PATH} && docker compose --env-file .env -f docker/docker-compose.yml -p demande-acompte up -d
}

function dacdown() {
    cd ${DAC_PATH} && docker compose --env-file .env -f docker/docker-compose.yml -p demande-acompte down --remove-orphans
}

function ninaup() {
    persodown
    luciedown
    eval ${NINA_COMPOSE} up -d --remove-orphans
    cd ${NINA_PATH}
    docker ps -a
}

function ninarestart() {
    ninadown
    ninaup
}

function actualdown() {
    comment "=====> actual =====> DOWN"
    ninadown
    luciedown
    dacdown
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
    memorymysqlup
}

function domup() {
    comment "=====> dom =====> UP"
    actualdown
    persodown
    cd {$SOGEDEP_PATH}
    docker compose up -d
}

function kube() {
    local namespace=$1
    if [ -z $namespace ]; then
        warning 'Usage : kube <namespace> (ie : eodurl T1-684-jobboard-email)'
        return 1
    fi

    kubectl cp ~/dotfiles/.miniBashrc commander:/root/.fredt_aliases --namespace=$namespace
    if [ $? != 0 ]; then
        error "copying minibash on kube pod $namespace has failed."
        return 1
    fi

    kubectl exec -it -n "$namespace" commander -- bash -c "source /root/.fredt_aliases && bash"
    return 0
}
