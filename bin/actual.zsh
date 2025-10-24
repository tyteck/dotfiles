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

function rebuildNinaDbIfNeeded() {
    dbnina -e "create database if not exists synchro_rh;" >/dev/null 2>&1
    comment "synchro_rh ✅"
}

function rebuildNinaTestingIfNeeded() {
    dbninamem -e "create database if not exists nina_testing;" >/dev/null 2>&1
    comment "nina_testing ✅"
}

function mk(){
    if inNina; then
        make --directory ${NINA_PATH} $@
    fi
    return
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
    local commandToRun="${dockerPrefix}${executablePath} --display-skipped --display-incomplete --display-deprecations --display-phpunit-deprecations $@"
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

function isRunning() {
    local program=$1
    pgrep $program >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        true
    else
        false
    fi
}

function passninapp() {
    local ninaEnvPath='/home/fred/Projects/infra/env_vars/nina-preprod-77a8'
    local ninaEnvFile="$ninaEnvPath/env_vars"
    if [[ ! -e $ninaEnvFile ]]; then
        echo "nina env file does not exist, refreshing ..."
        cd $ninaEnvPath && git pull && make decrypt
    fi
    echo "nina preprod db password is ... "
    cat $ninaEnvFile | grep DB_PASSWORD | cut -d'=' -f2
}

function passninadev() {
    local ninaEnvPath='/home/fred/Projects/infra/env_vars/nina-dev-a593'
    local ninaEnvFile="$ninaEnvPath/env_vars"
    if [[ ! -e $ninaEnvFile ]]; then
        echo "nina env file does not exist, refreshing ..."
        cd $ninaEnvPath && git pull && make decrypt
    fi
    echo "nina dev db password is ... "
    cat $ninaEnvFile | grep DB_PASSWORD | cut -d'=' -f2
}

function runshootdev() {
    sshoot start actual-dev
}

function sshninadev() {
    runshootdev
    gcloud container clusters get-credentials mutualise-dev --zone europe-west9-a --project mutualise-dev-db42 --internal-ip
    commander=$(kubectl get pods -n nina-dev | grep commander | grep Running | awk '{print $1}')
    kubectl exec -it $commander -n nina-dev -- /bin/bash
}

function runshootpp() {
    sshoot start actual-preprod
}

function runshootprod() {
    sshoot start actual-prod
}

function sshninapp() {
    runshootpp
    # run following command if needed
    gcloud container clusters get-credentials mutualise-preprod --zone europe-west9-a --project mutualise-preprod-c51e --internal-ip
    commander=$(kubectl get pods -n nina-preprod | grep commander | grep Running | awk '{print $1}')
    kubectl exec -it $commander -n nina-preprod -- /bin/bash
}

function sshninaprod() {
    runshootprod
    # run following command if needed
    gcloud container clusters get-credentials mutualise-prod --zone europe-west9-a --project mutualise-prod-f414 --internal-ip
    commander=$(kubectl get pods -n nina-prod | grep commander | grep Running | awk '{print $1}')
    kubectl exec -it $commander -n nina-prod -- /bin/bash
}

function pushninadev() {
    local branchName=$1
    pushnina dev ${branchName}
}

function pushninapp() {
    local branchName=$1
    pushnina preprod ${branchName}
}

function pushnina() {
    if [[ $# -ne 2 ]]; then
        warning 'Usage : pushninapp <ENVIRONMENT> <BRANCH_NAME> [front/back/both] (ie : pushninapp dev CHEW-29-ftp-pixid )'
        return 1
    fi

    local environment=$1
    local branchName=$2
    local gcloudEnv
    local triggerNamesToRun="deploy-front deploy-k8s-cloudrun"

    case $environment in
    "dev") gcloudEnv="nina-dev" ;;
    "preprod" | "pp") gcloudEnv="nina-preprod" ;;
    *)
        warning "environment ${environment} is unknown should be dev, preprod or pp"
        return 1
        ;;
    esac

    # recuperer le project id de nina-preprod
    ninaProjectId=$(gcloud projects list | grep $gcloudEnv | awk '{print $1}')
    if [ -z $ninaProjectId ]; then
        warning "gcloud project ${gcloudEnv} cannot be found"
        return 1
    fi

    echo "ninaProjectId : $ninaProjectId"
    # specifier le projet courant
    gcloud config set project $ninaProjectId

    # recuperer les triggers
    output=$(gcloud builds triggers list --region=europe-west9 --format=json)

    # recuperer les noms et id des triggers
    echo "$output" | jq -r '.[] | "\(.id) \(.name)"' | while IFS= read -r line; do
        triggerId=$(echo "$line" | awk '{print $1}')
        triggerName=$(echo "$line" | awk '{print $2}')

        # si c'est un trigger à deploy
        if in_array $triggerName $triggerNamesToRun; then
            echo "=====> Running trigger ${triggerName} ($triggerId) with branch ${branchName} on ${gcloudEnv} <====="
            gcloud builds triggers run $triggerId --branch $branchName --region=europe-west9
        fi
    done
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

function ninadbrefresh() {
    cd ${NINA_PATH} && artisan fred:dbrefresh
}

function ninadbreset() {
    docker volume rm -f nina_mysql-data
}

function ninaslipsfromuuid() {
    local uuid=$1
    if [ -z $uuid ]; then
        warning 'Usage : ninaslipsfromuuid <UUID> (ie : ninaslipsfromuuid 12345678-1234-1234-1234-123456789012)'
        return 1
    fi
    dbnina -e "select slips.timesheet_id, slips.anael_category_id, slips.type, slips.platform_category_code, slips.platform_category_label, slips.date, slips.quantity, slips.base_paid, slips.base_billed, slips.rate_paid, slips.rate_billed, slips.coefficient, slips.extra_data \
        from slips inner join timesheets on slips.timesheet_id=timesheets.id \
        where timesheets.uuid='${uuid}';"
}

function ninatimesheetfromuuid() {
    local uuid=$1
    if [ -z $uuid ]; then
        warning 'Usage : ninatimesheetfromuuid <UUID> (ie : ninatimesheetfromuuid 12345678-1234-1234-1234-123456789012)'
        return 1
    fi
    dbnina -e "select * \
        from timesheets \
        where timesheets.uuid='${uuid}';"
}

function ninaup() {
    persodown
    luciedown

    # config for pulling from europe-docker.pkg.dev
    cat ~/.docker/config.json | grep "europe-docker.pkg.dev" >/dev/null
    if [ $? != 0 ]; then
        gcloud auth configure-docker europe-docker.pkg.dev
    fi

    docker network inspect actual-network >/dev/null 2>&1
    if [ $? != 0 ]; then
        docker network create actual-network
    fi
    docker compose -f ${NINA_PATH}/docker/docker-compose.yml -p nina up -d
    if [ $? != 0 ]; then
        warning "command has failed."
        return
    fi
    cd ${NINA_PATH}
    rebuildNinaDbIfNeeded
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

function atlasclear() {
    if inNina; then
        find ${NINA_PATH}/app/storage/app/atlas/ -type f -name '*.csv' -exec rm -fv {} \;
    else
        warning "ONLY NINA FOR NOW"
    fi
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
