# LaraDocker
# This plugin is useful for those who are running multiple laravel containers.
# The purpose is being able to run artisan according to the project you are in
# to use it properly you should respect some requirements.
# - using container name
# - last part of the folder (where is stored artisan) should have the same name as your container
#  		/path/../to/<containername>/artisan

function isLaravelPath() {
    if fileExists 'artisan' || fileExists 'laravel/artisan' || fileExists 'app/artisan'; then
        true
    else
        false
    fi
}

function laravelFirstRun() {
    if ! isLaravelPath; then
        echo 'You are not in a laravel path.'
        return 1
    fi

    mkdir -p storage/framework/cache
    mkdir -p storage/framework/sessions
    mkdir -p storage/framework/testing
    mkdir -p storage/framework/views
}

function artisan() {
    if ! isLaravelPath; then
        echo 'You are not in a laravel path.'
        return 1
    fi    
    # get the container name
    local dockerPrefix=$(getDockerPrefix)

    # run artisan
    local commandToRun="noglob ${dockerPrefix}php artisan $@"
    local lastFolderName=$(getLastFolders)
    comment ${commandToRun}
    eval $commandToRun
    apacheandme .
}

function getDockerPrefix() {
    local lastFolderName=$(getLastFolders)
    local dockerPrefix=''
    if inLucie; then # lucie - Actual
        [ -z $LUCIE_COMPOSE ] && echo 'env var LUCIE_COMPOSE is not defined.' && return 1;
        dockerPrefix="${LUCIE_COMPOSE} exec php-nginx "
    elif inNina; then # nina - Actual
        dockerPrefix="docker compose -f ${NINA_PATH}/build/docker-compose.yml -p nina exec -e XDEBUG_MODE=off php-nginx "
    elif inDac; then # demande-acompte - Actual
        dockerPrefix="docker compose --env-file ${DAC_PATH}/.env -f ${DAC_PATH}/docker/docker-compose.yml -p demande-acompte exec php-nginx "
    elif inAnael; then
        dockerPrefix="docker compose -f ${ANAEL_PATH}/docker/docker-compose.yml --env-file=${ANAEL_PATH}/.project.env exec php-fpm "
    elif inAtlas; then
        dockerPrefix="docker compose -f ${ATLAS_PATH}/docker/docker-compose.yml --env-file=${ATLAS_PATH}/.project.env -p atlas exec php-nginx "
    elif isInstalled 'docker' && containerExists $lastFolderName; then
        dockerPrefix="docker exec -it $lastFolderName "
    fi
    echo $dockerPrefix
}

function pest() {
    local executablePath='vendor/bin/pest'

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

function tests() {
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

function stan() {
    local defaultPathToCheck='app database'
    local pathToCheck="${1:-$defaultPathToCheck}"
    local executablePath='vendor/bin/phpstan'

    if ! dockerFileExists $executablePath; then
        error "There is no ${executablePath} by there."
        return 1
    fi

    # get the command to access container
    local dockerPrefix=$(getDockerPrefix)

    if inNina; then # nina - Actual
        commandToRun="${dockerPrefix}${executablePath} analyze ${pathToCheck} --level max"
    else
        commandToRun="${dockerPrefix}${executablePath}"
    fi
    comment $commandToRun
    eval $commandToRun
}

function pint() {
    local executablePath='vendor/bin/pint'

    # get the command to access container
    local dockerPrefix=$(getDockerPrefix)

    if inDac || inNina || inLucie ; then # Actual
        commandToRun="${dockerPrefix}${executablePath} --config /app/vendor/actual/code-quality/pint.run.json --ansi"
    elif inAnaelApiHandler; then
        commandToRun="make fix"
    else
        commandToRun="./${executablePath}"
    fi
    comment $commandToRun
    eval $commandToRun
}

function getBaseFolder() {
    local directoryIWantTheBaseFrom=$1
    if [ -z $directoryIWantTheBaseFrom ]; then
        echo 'You should send one the folder you want to get the base folder from.'
        return 1
    fi

    local firstPathChar=${directoryIWantTheBaseFrom:0:1}

    local cutPosition=1
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

function getLastFolders() {
    # depthLevel is the first argument. if not set using 2 for depthLevel
    depthLevel=$1
    if [[ -z $depthLevel || $depthLevel -lt 1 ]];then
        depthLevel=1
    fi
    absolutePath=$(pwd)
    # splitting path 
    parts=(${(@s:/:)absolutePath})

    # getting nb items in tree
    nbItems=${#parts[@]}

    # defining start folder
    ((start = $nbItems - $depthLevel + 1))
    if [[ $start -lt 1 ]];then
        start=1
    fi 
    lastFolders=$parts[$start]
    ((start++))
    for ((index = $start; index <= $nbItems; index++));do
        lastFolders="${lastFolders}/${parts[index]}"
    done
    echo $lastFolders
}

# check if containerName is up and running
function containerExists() {
    local containerName=$1
    docker container inspect $containerName >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        true
    else
        false
    fi
}

function dockerFileExists(){
    local fileName=$1

    # get the command to access container
    local dockerPrefix=$(getDockerPrefix)

    # check if executable is present
    local commandToRun="${dockerPrefix}test -f ${fileName}"
    comment $commandToRun
    eval $commandToRun
    if [ $? -eq 0 ]; then
        true
    else
        false
    fi
}

# check if filename exists
function fileExists() {
    local fileName=$1
    if [ -f $fileName ]; then
        true
    else
        false
    fi
}

# check if filename is executable
function isFileExecutable() {
    local fileName=$1
    if [ -x $fileName ]; then
        true
    else
        false
    fi
}

# check if one program is installed on this computer
function isInstalled() {
    local programName=$1
    if [ -x "$(command -v $programName)" ]; then
        true
    else
        false
    fi
}

function lastLogFile(){
    if ! isLaravelPath; then
        echo 'You are not in a laravel path.'
        return 1
    fi

    local logPath='storage/logs'
    if [ ! -d 'storage/logs' ]; then
        # specific lucie (Actual)
        logPath='laravel/storage/logs'
    fi

    # search for classic laravel.log first
    local fileToTail="$logPath/laravel.log"
    if [ -f $fileToTail ]; then
        echo $fileToTail
        return 0
    fi

    # search for daily log first
    fileToTail=$(find ${logPath} -name 'laravel*.log' | sort -r | head -1)
    if [ ! -z $fileToTail ]; then
        echo $fileToTail
        return 0
    fi
    
    echo 'Seems to have no log file by there.'
    return 1
}

function tailLastLog() {
    local lastLogFileResult=$(lastLogFile)
    if [ $? -ne 0 ]; then
        echo $lastLogFileResult
        return 1
    fi
    
    comment "tailing $lastLogFileResult"
    tail -f $lastLogFileResult -n 200
}

function emptyLastLog() {
    local lastLogFileResult=$(lastLogFile)
    if [ $? -ne 0 ]; then
        echo $lastLogFileResult
        return 1
    fi

    emptyFile $lastLogFileResult
}

function catErrorsFromLog() {
    local lastLogFileResult=$(lastLogFile)
    if [ $? -ne 0 ]; then
        echo $lastLogFileResult
        return 1
    fi
    
    cat $lastLogFileResult | grep ERROR
}

# sample test
# if inNina;then echo "IN";else echo "out";fi
function inNina() {
    inPath "nina"
}

# sample test
# if inLucie;then echo "IN";else echo "out";fi
function inLucie() {
    inPath "lucie"
}

function inDac() {
    inPath "demande-acompte"
}

function inAnael() {
    inPath "anael-laravel"
}

function inAtlas() {
    inPath "atlas-back"
}

function inAnaelApiHandler() {
    inPath "anael-api-handler"
}

# sample test
# if inPath "lorem";then echo "IN";else echo "out";fi
function inPath() {
    local pathToCheck=$1
    if [ -z $pathToCheck ]; then
        echo 'You should give the path you want to check you are in.'
        return 1
    fi
    local absolutePath=$(pwd)
    case $absolutePath in
        *"${pathToCheck}"*)
            return 0
            ;;
    esac
    return 1
}

function migratePath(){
    local migratePath=''
    if inLucie; then
        migratePath=' --path="database/migrations/*"'
    fi
    echo $migratePath
}

function am(){
    local cmd="artisan migrate$(migratePath)"
    eval $cmd
}

function amf(){
    local cmd="artisan migrate:fresh$(migratePath)"
    eval $cmd
}

function amfs(){
    local cmd
    if inNina; then # nina - Actual
        cmd="artisan migrate:fresh --seed --seeder=LocalSeeder"
    else
        cmd="artisan migrate:fresh --seed$(migratePath)"
    fi
    eval $cmd
}

function amr(){
    local cmd="artisan migrate:rollback $(migratePath)"
    eval $cmd
}

function ams(){
    local cmd="artisan migrate:status$(migratePath)"
    eval $cmd
}

alias acc='artisan cache:clear && artisan config:clear'
alias ads='artisan db:seed'
alias aie='artisan ide-helper:eloquent'
alias aig='artisan ide-helper:generate'
alias al='artisan list'
alias aoc='artisan optimize:clear'
alias arc='artisan route:clear'
alias arl='artisan route:list'
alias aql='artisan queue:listen'
alias aqf='artisan queue:flush'
alias aqm='artisan queue:monitor podwww,default'
alias aqr='artisan queue:restart'
alias arall='artisan queue:restart && artisan optimize:clear'
alias atp='artisan test --parallel'
alias avp='artisan vendor:publish'
alias tinker='artisan tinker'
alias insights='artisan insights --no-interaction --verbose'
alias tstop='tests --stop-on-failure --stop-on-error'
