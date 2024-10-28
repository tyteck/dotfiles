alias code='PHP_CS_FIXER_IGNORE_ENV=1 | code'
alias history='history -E'
alias myipeth0='ip addr show enp2s0'
alias please='sudo'
alias reboot='restart'
alias restart='please shutdown -r now'
alias zrc='exec zsh'

export PROJECTS_PATH="$HOME/Projects"
# actual
export NINA_PATH=${PROJECTS_PATH}/nina
export NINA_BACK_PATH=${NINA_PATH}/app
export NINA_FRONT_PATH=${NINA_PATH}/front/app/web
export DAC_PATH=${PROJECTS_PATH}/demande-acompte
export LUCIE_PATH=${PROJECTS_PATH}/lucie
export ANAEL_PATH=${PROJECTS_PATH}/anael-laravel

# Perso
export PODMYTUBE_PATH="$PROJECTS_PATH/podmytube"
export INSPIRATION_PATH="$PROJECTS_PATH/ecran-inspirant"
export MAILHOG_PATH='/var/opt/docker/mailhog'
export MYSQL_SERVER_PATH="/var/opt/docker/mysqlserver"
export PHPMYADMIN_PATH="/var/opt/docker/phpmyadmin"
export MEMORYMYSQL_PATH="/var/opt/docker/memorymysql"
export DEMO_PRINT_FACTORY_PATH="$PROJECTS_PATH/demo-print-factory"
export TEMP_PATH="$PROJECTS_PATH/temperatures"
export ECRAN_PATH="$PROJECTS_PATH/ecran-inspirant"
export DOCS_PATH="$PROJECTS_PATH/apidocuments"
export POKER_PATH="$PROJECTS_PATH/poker"
export JOB_PATH="$PROJECTS_PATH/jobboard"
# required to use php-cs-fixer on php 8.2 (fredt 2023-03-03)
export PHP_CS_FIXER_IGNORE_ENV=1

APACHE_USER=www-data
APACHE_GROUP=www-data
if [ isMacos ]; then
    APACHE_USER=_www
    APACHE_GROUP=_www
fi

export LD_LIBRARY_PATH=$(which openssl)

# monit
alias monitRestart='sudo monit -t && sudo monit reload'

# vscode
alias vsdot="cd ${HOME}/dotfiles && code ."
alias vsecran="cd ${INSPIRATION_PATH} && screen -d -m npm run dev && code ."
alias vstemp="cd ${TEMP_PATH} && screen -d -m npm run dev && code ."
alias vsecran="cd ${ECRAN_PATH} && code ."
alias vsjob="cd ${JOB_PATH} && code ."

# actual
alias vsninaback="cd ${NINA_BACK_PATH} && code ."
alias vsninafront="cd ${NINA_FRONT_PATH} && code ."
alias vslucie="cd ${LUCIE_PATH}/laravel && code ."
alias vsanael="cd ${ANAEL_PATH} && code ."
alias vsdac="cd ${DAC_PATH} && code ."

# ubuntu
alias whichdesktop='env | grep XDG_CURRENT_DESKTOP'
alias fixbrokeninstall="sudo apt install -y --fix-broken"

# default db shortcuts
alias dbprod="mysql --login-path=prod podmytube"
alias dbblog="mysql --login-path=blog blogging"

alias c='clear'
alias fullpath='readlink -f'
# docker & docker compose
alias dokbuild='docker compose build'
alias dokconfig='docker compose config'
alias dokcp='docker cp'
alias dokdown='docker compose down --remove-orphans'
alias dokexec='docker exec -it'
alias doklog='docker logs -f'
alias doknames='docker ps --format "{{.Names}}"'
alias dokrm='docker container rm -f'
alias dokprune='docker system prune -f'
alias dokrestart='docker compose down --remove-orphans && docker compose up -d'
alias dokrestartdev='docker compose down && docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d'
alias dokrestartfred='docker compose down && docker compose -f docker-compose.yml -f docker-compose.fred.yml up -d'
alias doktus='docker ps -a'
alias dokillall='docker kill $(docker ps -q)'
alias dokup='docker compose up -d'
alias dokupprod='docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d'
alias podexec='docker exec -it podmytube'
alias dbcourbesprod='mysql --login-path=courbes'

# Symfony
alias sfc='php bin/console'

# Golang
alias got='go test'
alias gor='go run'
alias gob='go build'

# screen
alias sls='screen -ls'

# stripe
alias stripelisten='screen -S "stripe-cli" -d -m stripe listen --forward-to dashboard.pmt.local/stripe/webhooks'

# Composer
alias composer='composer --ignore-platform-reqs'
alias cdu='composer dump-autoload'

# linux
alias edithosts='sudo vim /etc/hosts'
alias etchosts='sudo vim /etc/hosts'
alias editsshconfig='vim ~/.ssh/config'
alias sshconfig='vim ~/.ssh/config'
alias editlocalconf='vim ~/.local.conf'
alias biggestfolders='du -a . | sort -n -r | head -n 10'
alias biggestfiles='du -Sh . | sort -rh | head -20'

# Go/Golang
alias gor='go run'
alias got='go test'
alias gorm='gor main.go'

# apt
alias apt='sudo apt -y'
alias aptu='apt update'
alias aptg='apt upgrade'
alias aptclean='apt autoremove'

# apt
alias fullapt='sudo apt-get update -q -y && \
    sudo apt-get upgrade -q -y && \
    sudo apt-get autoclean -q -y && \
    sudo apt-get autoremove -q -y'

case $HOST in
'mini-forum' | 'debian' | 'Tour-fred')
    alias shutdown='fullapt ; please shutdown -h now'
    if hash ansible-playbook 2>/dev/null; then
        ansiblePlaybooksDirectory=$HOME/ansible-playbooks
        if [ -d $HOME/ansible-playbooks/ ]; then
            alias fullapt="ansible-playbook $ansiblePlaybooksDirectory/apt-upgrade.yml -i $ansiblePlaybooksDirectory/inventory/podmytube"
        else
            echo 'ansible-playbook is installed but you have to clone git@github.com:tyteck/ansible-playbooks.git'
        fi
    fi
    ;;
*)
    alias shutdown='please shutdown -h now'
    ;;
esac

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
#                               	COMMODITIES
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

function foolperso() {
    echo "tyteck"
}

function emptyFile() {
    local fileToEmpty=$1
    if [ -z $fileToEmpty ]; then
        error 'You should specify the file path you want to empty'
        return 1
    fi

    if [ ! -f $fileToEmpty ]; then
        error 'The file you want to purge does not exist.'
        return 1
    fi

    sudo truncate -s 0 $fileToEmpty
    if [ $? -eq 0 ]; then
        comment "$fileToEmpty is now empty"
        return 0
    fi
    error 'command has failed.'
    return 1
}

function whatsmyip() {
    local myIp=$(curl https://ipinfo.io/ip --silent)
    echo $myIp
}

function userExists() {
    id "$1" &>/dev/null
}

function gcloudPerso() {
    gcloud config configurations activate perso
}


function updateGcloudApiIp(){
    gcloudPerso
    gcloud beta services api-keys update 54d687c1-ea47-4648-b722-fc5b74abb439 --allowed-ips=$(whatsmyip)
}

function itsmine() {
    for FILE in "$@"; do
        if [ -f $FILE ]; then
            sudo chown $USER:$GROUP $FILE
        elif [ -d $FILE ]; then
            sudo chown -R $USER:$GROUP $FILE
        else
            echo "{$FILE} do not exists. Check your path !"
            continue
        fi
    done
    return 0
}

function apacheandme() {
    for FILE in "$@"; do
        if [ -f $FILE ]; then
            sudo chown www-data:$USER $FILE && sudo chmod g+w $FILE
        elif [ -d $FILE ]; then
            sudo chown -R www-data:$USER $FILE && sudo chmod -R g+w $FILE
        else
            echo "{$FILE} do not exists. Check your path !"
            continue
        fi
    done
    return 0
}

# extract one value from .env file
# @param $1 variable name
# @param $2 file where is set this variable (default .env)
function readVar() {
    local VAR_NAME=$1
    local FILE_NAME=$2
    if [ -z $FILE_NAME ]; then
        FILE_NAME='.env'
    fi
    VAR=$(grep $VAR_NAME $FILE_NAME | xargs)
    IFS="=" read -rA VAR <<<"$VAR"
    # ${VAR[1]} is the key
    # ${VAR[2]} is the value
    echo ${VAR[2]}
}

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
#                               	DOCKER
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

# get the ip address for one container
function dokip() {
    local CONTAINER_NAME=$1
    docker inspect $CONTAINER_NAME --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

function dokips() {
    for CONTAINER_NAME in $(docker ps --format '{{.Names}}'); do
        echo $CONTAINER_NAME --- $(dokip $CONTAINER_NAME)
    done
}

function dokrmi() {
    local IMAGE_NAME=$1
    docker rmi $(docker image ls --filter "reference=$IMAGE_NAME" -q)
}

function dokexists() {
    local containerName=$1

    if [ -z "$containerName" ]; then
        echo 'You should give a container name as an argument to check container existence.'
        return 1
    fi
    # getting image is a way to avoid getting network of the same name
    # by example there is a network nginx-proxy and a container
    cmd="docker inspect ${containerName} --format='{{.Config.Image}}' >/dev/null 2>/dev/null"
    #echo $cmd
    eval $cmd
    return $?
}

function in_array() {
    local needle="$1"
    local haystack="$2"
    
    # Split the string into an array
    local values_array=(${(@s/ /)haystack})

    # Iterate through the elements in the array
    for item in $values_array; do
        if [[ $item == $needle ]]; then
            return 0 # Return success (true) if the value is found
        fi
    done

    return 1 # Return failure (false) if the value is not found
}

#my_string="item1 item2 item3 item4"
#value_to_check="item3"
#if in_array "$value_to_check" "$my_string"; then
#    echo "$value_to_check is in the string."
#else
#    echo "$value_to_check is not in the string."
#fi

# this function will set builtin audio as default input and output
function setaudio() {
    case $HOST in
    'XPS-13')
        sennheiser
        ;;
    'mini-forum')
        arctis
        ;;
    *)
        comment 'to be done'
        return 1
        ;;
    esac
}

function sennheiser() {
    # obtained with `pactl list short sinks`
    audiooutput 'alsa_output.usb-Sennheiser_Communications_Sennheiser_USB_headset-00'

    # obtained with `pactl list short sources`
    audioinput 'alsa_input.usb-Sennheiser_Communications_Sennheiser_USB_headset-00'
}

function arctis() {
    # obtained with `pactl list short sinks`
    audiooutput 'alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.analog-stereo'

    # obtained with `pactl list short sources`
    audioinput 'alsa_input.usb-SteelSeries_SteelSeries_Arctis_7-00.analog-mono'
}

function audiooutput() {
    local audioOutputName=$1
    if [ -z $audioOutputName ]; then
        error 'You should specify name of audio output as it appears in `pactl list short sinks`'
        return 1
    fi

    local audioOutputLine="$(pactl list short sinks | grep ${audioOutputName})"
    if [ ! -z $audioOutputLine ]; then
        local foundAudioOutputName="$(cut -f2 <<<$audioOutputLine)"
        comment "setting $foundAudioOutputName as default output"
        pactl set-default-sink $foundAudioOutputName
        return 0
    fi

    error "This audio device (${audioOutputName}) was not found"
}

function audioinput() {
    local audioInputName=$1
    if [ -z $audioInputName ]; then
        error 'You should specify name of audio input as it appears in `pactl list short sources`'
        return 1
    fi

    local audioInputLine="$(pactl list short sources | grep ${audioInputName})"
    if [ ! -z $audioInputLine ]; then
        local foundAudioInputName="$(cut -f2 <<<$audioInputLine)"
        comment "setting $foundAudioInputName as default input"
        pactl set-default-source $foundAudioInputName
        return 0
    fi

    error "This audio device (${audioInputName}) was not found"
}

function dir() {
    for folder in $(ls -d *); do
        if [ $folder = "proc" ]; then
            continue
        fi
        sudo du -hs $folder 2>/dev/null
    done
}

function containerup() {
    local containerName=$1
    local containerRoot=$2

    if [ -z $containerName ]; then
        echo 'You should give a container name as an argument to compose it up.'
        return 1
    fi

    if [ -z $containerRoot ]; then
        echo 'You should give a container root/path as an argument to compose it up.'
        return 1
    fi

    cd $containerRoot
    
    if dokexists "$containerName"; then
        comment "$containerName is already up"
        return 0
    fi

    dokup
}

function containerdown() {
    local containerName=$1
    local containerRoot=$2

    if [ -z $containerName ]; then
        echo 'You should give a container name as an argument to compose it down.'
        return 1
    fi

    if [ -z $containerRoot ]; then
        echo 'You should give a container root/path as an argument to compose it down.'
        return 1
    fi

    cd $containerRoot 

    if ! dokexists $containerName; then
        comment "$containerName is already down"
        return 0
    fi

    dokdown
}

function mysqlup() {
    containerup "mysqlserver-db-1" "$MYSQL_SERVER_PATH"
}

function mysqldown() {
    containerdown "mysqlserver-db-1" "$MYSQL_SERVER_PATH"
}

function phpmyadminup() {
    containerup "phpmyadmin" "$PHPMYADMIN_PATH"
}

function phpmyadmindown() {
    containerdown "phpmyadmin" "$PHPMYADMIN_PATH"
}

function mailup() {
    containerup "mailhog" "$MAILHOG_PATH"
}

function maildown() {
    containerdown "mailhog" "$MAILHOG_PATH"
}

function memorymysqlup() {
    containerup "memorymysql" "$MEMORYMYSQL_PATH"
}

function memorymysqldown() {
    containerdown "memorymysql" "$MEMORYMYSQL_PATH"
}


# ==================================
# Podmytube
# ==================================
function podup() {
    persoup
    containerup "podmytube" "$PODMYTUBE_PATH"
    cd $PODMYTUBE_PATH
}

function poddown() {
    containerdown "podmytube" "$PODMYTUBE_PATH"
}

# ==================================
# Temperatures
# ==================================
function tempup() {
    persoup
    containerup "temperatures" "$TEMP_PATH"
}

function tempdown() {
    containerdown "temperatures" "$TEMP_PATH"
}

# ==================================
# GDPR
# ==================================
function docsup() {
    persoup
    containerup "apidocuments" "$DOCS_PATH"
}

function docsdown() {
    containerdown "apidocuments" "$DOCS_PATH"
}

# ==================================
# POKER
# ==================================
function pokerup() {
    persoup
    containerup "poker" "$POKER_PATH"
}

function pokerdown() {
    containerdown "poker" "$POKER_PATH"
}

# ==================================
# Ecran Inspirant
# ==================================
function ecranup() {
    persoup
    containerup "ecran-inspirant" "$ECRAN_PATH"
}

function ecrandown() {
    containerdown "ecran-inspirant" "$ECRAN_PATH"
}

# ==================================
# Job Board
# ==================================
function jobup() {
    cd ${JOB_PATH} 
    screen -dm npm run dev
    php artisan native:serve
}


# ==================================
# Common
# ==================================

function persoup() {
    comment "⬆️  perso ⬆️"
    mysqlup
    phpmyadminup
    mailup
    memorymysqlup
}

function persodown() {
    comment "⬇️  perso ⬇️"
    gcloudActual
    mysqldown
    phpmyadmindown
    maildown
    memorymysqldown
    poddown
    tempdown
    docsdown
    pokerdown
    ecrandown
}

function demoup() {
    comment "=====> demo-print-factory =====> UP"
    persoup
    cd $DEMO_PRINT_FACTORY_PATH
}

function demodown() {
    comment "=====> demo-print-factory =====> DOWN"
    persodown
    cd $HOME
}

function actualup() {
    echo "actualup is doing nothing and it's 👍"
}

function actualdown() {
    echo "actualdown is doing nothing and it's 👍"
}

function installdeb() {
    local filepath=$1
    if [ -z $filepath ]; then
        error 'You should specify the deb file path you want to install'
        return 1
    fi

    comment "Installing $filepath ..."
    sudo dpkg -i $filepath && rm -f $filepath
    if [ $? -ne 0 ]; then
        error "Installing $filepath has failed"
        return 1
    fi
    comment "Installation successful"
    return 0
}

function refreshmycontainers() {
    for container in mailhog memorymysql mysqlserver nginx-proxy phpmyadmin; do
        echo "====> refreshing $container"
        cd /var/opt/docker/$container
        git pull
        dokrestart
    done
}

function refreshimages() {
    for image in jwilder/nginx-proxy:alpine jrcs/letsencrypt-nginx-proxy-companion mysql:5.7 phpmyadmin/phpmyadmin mailhog/mailhog; do
        echo "====> refreshing $image"
        docker pull $image
    done
}
