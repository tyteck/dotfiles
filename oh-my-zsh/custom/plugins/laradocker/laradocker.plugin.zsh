# LaraDocker
# This plugin is useful for those who are running multiple laravel containers.
# The purpose is being able to run artisan according to the project you are in
# to use it properly you should respect some requirements.
# - using container name
# - last part of the folder (where is stored artisan) should have the same name as your container
#  		/path/../to/<containername>/artisan

function isLaravelPath() {
    if fileExists "artisan" || fileExists "laravel/artisan"; then
        true
    else
        false
    fi
}

function laravelFirstRun() {
    if ! isLaravelPath; then
        echo "You are not in a laravel path."
        return 1
    fi

    mkdir -p storage/framework/cache
    mkdir -p storage/framework/sessions
    mkdir -p storage/framework/testing
    mkdir -p storage/framework/views
}

function artisan() {
    if ! isLaravelPath; then
        echo "You are not in a laravel path."
        return 1
    fi

    # get the container name
    dockerPrefix=$(getDockerPrefix)

    # run artisan
    commandToRun="noglob ${dockerPrefix}php artisan $@"
    comment ${commandToRun}
    eval $commandToRun
}

function getDockerPrefix() {
    containerName=$(getLastFolder)
    dockerPrefix=''
    if [[ "$containerName" = "lucie" || "$containerName" = "laravel" ]]; then # lucie - Actual
        dockerPrefix="docker-compose -f ${LUCIE_PATH}/docker/docker-compose.yml -p actual exec php-nginx "
    elif isInstalled "docker" && containerExists $containerName; then
        dockerPrefix="docker exec -it --user www-data $containerName "
    fi
    echo $dockerPrefix
}

function tests() {
    executablePath="vendor/bin/phpunit"
    # checking if executable is there
    if ! fileExists $executablePath && ! fileExists "laravel/$executablePath"; then
        echo "phpunit is not available in path ($executablePath)."
        return 1
    fi

    # get the container name
    dockerPrefix=$(getDockerPrefix)

    commandToRun="${dockerPrefix}${executablePath} $@"
    comment $commandToRun
    eval $commandToRun
}

function getBaseFolder() {
    directoryIWantTheBaseFrom=$1
    if [ -z $directoryIWantTheBaseFrom ]; then
        echo "You should send one the folder you want to get the base folder from."
        return 1
    fi

    firstPathChar=${directoryIWantTheBaseFrom:0:1}

    cutPosition=1
    if [[ $firstPathChar == '/' ]]; then
        cutPosition=2
    fi
    baseDirectory=$(echo "$directoryIWantTheBaseFrom" | cut -d "/" -f${cutPosition})
    echo $baseDirectory
}

# grab the last part of path
# /path/to/folder => folder
function getLastFolder() {
    echo $(basename $(pwd))
}

# check if containerName is up and running
function containerExists() {
    containerName=$1
    if [ "$(docker ps -a | grep $containerName)" ]; then
        true
    else
        false
    fi
}

# check if filename exists
function fileExists() {
    fileName=$1
    if [ -f $fileName ]; then
        true
    else
        false
    fi
}

# check if filename is executable
function isFileExecutable() {
    fileName=$1
    if [ -x $fileName ]; then
        true
    else
        false
    fi
}

# check if one program is installed on this computer
function isInstalled() {
    programName=$1
    if [ -x "$(command -v $programName)" ]; then
        true
    else
        false
    fi
}

function tailLastLog() {
    if ! isLaravelPath; then
        echo "You are not in a laravel path."
        return 1
    fi

    logPath='storage/logs'
    if [ ! -d 'storage/logs' ]; then
        # specific lucie (Actual)
        logPath='laravel/storage/logs'
    fi

    # search for classic laravel.log first
    fileToTail="$logPath/laravel.log"
    if [ -f $fileToTail ]; then
        tail -f $fileToTail -n 200
        return 0
    fi

    # search for daily log first
    fileToTail=$(find ${logPath} -name 'laravel*.log' | sort -r | head -1)
    if [ ! -z $fileToTail ]; then
        tail -f $fileToTail -n 200
        return 0
    fi
    echo "No laravel logs file by there. Are you sure you are in the right place ?"
}

alias acc="artisan cache:clear"
alias ads="artisan db:seed"
alias aig="artisan ide-helper:generate"
alias aie="artisan ide-helper:eloquent"
alias al="artisan list"
alias arl="artisan route:list"
alias arc="artisan route:clear"
alias am="artisan migrate"
alias amf="artisan migrate:fresh"
alias amfs="artisan migrate:fresh --seed"
alias amr="artisan migrate:rollback"
alias ams="artisan migrate:status"
alias aoc="artisan optimize:clear"
alias aqf="artisan queue:flush"
alias aqr="artisan queue:restart"
alias arall="artisan queue:restart && artisan optimize:clear"
alias at="artisan test"
alias atp="artisan test --parallel"
alias tinker="artisan tinker"
alias insights="artisan insights --no-interaction --verbose"
