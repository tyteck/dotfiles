#!/usr/bin/zsh

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

export LOCAL_DOCKER_IP=$(docker network inspect bridge --format='{{index .IPAM.Config 0 "Gateway"}}')
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

alias elasticreset='artisan elasticsearch:delete && artisan elasticsearch:rebuild'
alias seedocs='artisan db:seed --class DocumentsSeeder && elasticreset'
alias fredseeder='artisan db:seed --class FredSeeder'
alias actualGcloud='gcloud config configurations activate actual'
alias ninadecrypt='docker compose -f /home/fred/Projects/nina/build/docker-compose.yml -p nina run tools gpg --quiet --batch --yes --decrypt --output app/app/.env.ci app/app/.env.ci.gpg'
alias ninaencrypt='docker compose -f /home/fred/Projects/nina/build/docker-compose.yml -p nina run tools gpg --symmetric --cipher-algo AES256 app/app/.env.ci'

#
#-------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------
#
function rebuildLucieTestingIfNeeded() {
    dblucielocal -e "create database if not exists actual_testing;" >/dev/null 2>&1
    comment "actual_testing ✅"
}

function rebuildNinaTestingIfNeeded() {
    dbninamem -e "create database if not exists nina_testing;" >/dev/null 2>&1
    comment "nina_testing ✅"
}

function tests() {
    if inLucie; then
        rebuildLucieTestingIfNeeded
    elif inNina; then
        rebuildNinaTestingIfNeeded
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

function gcloudActual() {
    gcloud config configurations activate actual
}

function pushluciepp() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushluciepp <BRANCH_NAME> (ie : pushluciepp s21-17)'
        return 1
    fi

    actualGcloud
    gcloud config set project eactual-preprod

    rungGcloudTriggersWithBranch $branchName
}

function pushninadev() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushninadev <BRANCH_NAME> (ie : pushninadev develop)'
        return 1
    fi

    actualGcloud
    gcloud config set project synchro-rh-dev

    rungGcloudTriggersWithBranch $branchName
}

function pushluciedev() {
    local branchName=$1
    if [ -z $branchName ]; then
        warning 'Usage : pushluciedev <BRANCH_NAME> (ie : pushluciedev s21-17)'
        return 1
    fi

    actualGcloud
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

    actualGcloud
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

    actualGcloud
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
    actualGcloud
    cmd="gcloud beta builds triggers run ${triggerId} --branch ${branchName}"
    comment "running : {$cmd} for $triggerName"
    eval $cmd
}

function luciedown() {
    cd ${LUCIE_PATH}/..
    make down
}

function lucieup() {
    persodown
    ninadown
    logFile=${LUCIE_PATH}/storage/logs/laravel-$(date "+%Y-%m-%d").log
    touch $logFile && sudo chown www-data:fred $logFile
    cd ${LUCIE_PATH}/..
    make up
    cd ${LUCIE_PATH}
}

function lucierestart() {
    luciedown
    lucieup
}

function ninaup() {
    persodown
    luciedown
    docker network inspect actual-network >/dev/null 2>&1
    if [ $? != 0 ]; then
        docker network create actual-network
    fi
    docker compose -f ${NINA_PATH}/build/docker-compose.yml -p nina up -d
    if [ $? != 0 ]; then
        warning "command has failed."
        return
    fi
    cd ${NINA_PATH}
    docker ps -a
}

function ninarestart() {
    ninadown
    ninaup
}

function ninastart() {
    cd ${NINA_PATH}/front
    docker compose -f docker/docker-compose.yml -p nina run --rm -p 127.0.0.1:3000:3000 node pnpm start
}

function ninadown() {
    docker compose -f ${NINA_PATH}/front/docker/docker-compose.yml -p nina down --remove-orphans
}

function dacup() {
    persodown
    cd ${DAC_PATH} && docker compose --env-file .env -f docker/docker-compose.yml -p demande-acompte up -d
}

function dacdown() {
    cd ${DAC_PATH} && docker compose --env-file .env -f docker/docker-compose.yml -p demande-acompte down --remove-orphans
}

function atlasdown() {
    cd ${ATLAS_PATH} && make up
}

function atlasdown() {
    cd ${ATLAS_PATH} && make down
}

function anaelup() {
    persodown
    cd ${ANAEL_PATH} && make up
}

function anaeldown() {
    cd ${ANAEL_PATH} && make down
}

function actualdown() {
    comment "⬇️  actual ⬇️"
    ninadown
    luciedown
    dacdown
    anaeldown
    atlasdown
}

function persoup() {
    comment "⬆️  perso ⬆️"
    actualdown
    docker network inspect local >/dev/null 2>&1
    if [ $? != 0 ]; then
        docker network create local
    fi
    mysqlup
    phpmyadminup
    mailup
    memorymysqlup
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
