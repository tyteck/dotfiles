alias zrc='source ~/.zshrc && echo "sourced !"'
alias please='sudo'
alias restart='please shutdown -r now'
alias reboot='restart'

PROJECTS_PATH="$HOME/Projects"
PODMYTUBE_PATH="$PROJECTS_PATH/podmytube"
REDUCBOX_PATH="$PROJECTS_PATH/reducbox"
WEPADEL_PATH="$PROJECTS_PATH/wepadel"
GPU_PATH="$PROJECTS_PATH/gpudispo"
MAILHOG_PATH="/var/opt/docker/mailhog"
NGINX_PROXY_PATH="/var/opt/docker/nginx-proxy"
MYSQL_SERVER_PATH="$PROJECTS_PATH/mysqlserver"
PHPMYADMIN_PATH="$PROJECTS_PATH/phpmyadmin"

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

# ubuntu
alias whichdesktop='env | grep XDG_CURRENT_DESKTOP'

# default db shortcuts
alias dbprod="mysql --login-path=prod podmytube"

alias c='clear'
alias fullpath='readlink -f'
# docker & docker compose
alias dokbuild="docker-compose build"
alias dokconfig="docker-compose config"
alias dokcp="docker cp"
alias dokdown="docker-compose down --remove-orphans"
alias dokexec="docker exec -it"
alias doklog="docker logs -f"
alias doknames="docker ps --format '{{.Names}}'"
alias dokrm="docker container rm -f"
alias dokprune="docker system prune -f"
alias dokrestart="docker-compose down --remove-orphans && docker-compose up -d"
alias dokrestartdev="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d"
alias dokrestartfred="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.fred.yml up -d"
alias doktus="docker ps -a"
alias dokup="docker-compose up -d"
alias dokupprod="docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

# shortcut to start containers
alias mysqlUp="cd $MYSQL_SERVER_PATH && gpull && dokup && cd -"
alias mysqlDown="cd $MYSQL_SERVER_PATH && dokdown && cd -"

alias phpmyadminUp="cd $PHPMYADMIN_PATH && gpull && dokup && cd -"
alias phpmyadminDown="cd $PHPMYADMIN_PATH && dokdown && cd -"

alias mailup="cd $MAILHOG_PATH && dokup && cd -"
alias maildown="cd $MAILHOG_PATH && dokdown && cd -"

alias wepadelup="reducdown && poddown && cd $WEPADEL_PATH && gpull && dokup && code ."
alias wepadeldown="cd $WEPADEL_PATH && dokdown && cd -"

alias nginxup="cd $NGINX_PROXY_PATH && dokup && gpull && cd -"
alias nginxdown="cd $NGINX_PROXY_PATH && dokdown && cd -"

alias gpuup="reducdown && poddown && mysqlUp && phpmyadminUp && cd $GPU_PATH && gpull && dokup && code ."
alias gpudown="cd $GPU_PATH && dokdown && cd -"

alias podup="reducdown && mysqlUp && phpmyadminUp && cd $PODMYTUBE_PATH && gpull && dokup && code ."
alias poddown="cd $PODMYTUBE_PATH && dokdown && cd -"

alias reducdown="cd $REDUCBOX_PATH && docker-compose down && cd -"
alias reducup="poddown && mysqlDown && phpmyadminDown && cd $REDUCBOX_PATH && gpull && dokup && code ."
alias reducrestart="cd $REDUCBOX_PATH && docker-compose restart reducbox"
alias podexec="docker exec -it --user www-data podmytube"

# Symfony
alias sfc='php bin/console'

# Php
alias phpunit='./vendor/bin/phpunit --colors=always'

# npm
alias nrtest='npm run test'
alias upgradeNpm='sudo npm install -g npm'

# screen
alias sls='screen -ls'

# stripe
alias stripelisten='screen -S "stripe-cli" -d -m stripe listen --forward-to dashboard.pmt.local/stripe/webhooks'

# Composer
alias composer='docker run --rm -v $(pwd):/app composer:latest '
alias cdu='composer dump-autoload --ignore-platform-reqs'
alias compUpdate='composer update --ignore-platform-reqs'
alias compUpgrade="composer upgrade --ignore-platform-reqs"
alias compInstall="composer install --ignore-platform-reqs"
alias compRequire="composer require --ignore-platform-reqs"
alias compRemove="composer remove --ignore-platform-reqs"

# linux
alias edithosts='sudo vim /etc/hosts'
alias editsshconfig='vim ~/.ssh/config'
alias biggestfolders='du -a . | sort -n -r | head -n 10'
alias biggestfiles='du -Sh . | sort -rh | head -20'

# Go/Golang
alias gor='go run'
alias gorm='gor main.go'

# apt
alias fullapt='sudo apt-get update -q -y && \
    sudo apt-get upgrade -q -y && \
    sudo apt-get autoclean -q -y && \
    sudo apt-get autoremove -q -y'

case $HOST in
"mini-forum" | "debian")
    alias shutdown="fullapt && please shutdown -h now"
    if hash ansible-playbook 2>/dev/null; then
        ansiblePlaybooksDirectory=$HOME/ansible-playbooks
        if [ -d $HOME/ansible-playbooks/ ]; then
            alias fullapt="ansible-playbook $ansiblePlaybooksDirectory/apt-upgrade.yml -i $ansiblePlaybooksDirectory/inventory/podmytube"
        else
            echo "ansible-playbook is installed but you have to clone git@github.com:tyteck/ansible-playbooks.git"
        fi
    fi
    ;;
*)
    alias shutdown="please shutdown -h now"
    ;;
esac

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
#                               	COMMODITIES
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

function isMacos() {
    if [ $(uname -s) = 'Darwin' ]; then
        true
    else
        false
    fi
}

function emptyFile() {
    local fileToEmpty=$1
    if [ -z $fileToEmpty ]; then
        error "You should specify the file path you want to empty"
        return 1
    fi

    if [ ! -f $fileToEmpty ]; then
        error "The file you want to purge does not exist."
        return 1
    fi

    : >$fileToEmpty
    if [ $? -eq 0 ]; then
        comment "$fileToEmpty is now empty"
        return 0
    fi
    error "command has failed."
    return 1
}

function apacheonly() {
    for ITEM in "$@"; do
        if [ -f $ITEM ]; then
            sudo chown www-data:www-data $ITEM
            sudo chmod g+rw $ITEM
        elif [ -d $ITEM ]; then
            sudo chown -R www-data:www-data $ITEM
            sudo chmod -R g+rw $ITEM
        else
            warning "{$ITEM} is not a valid element to change permssions on."
            continue
        fi
    done
    return 0
}

function apacheUser() {
    local apacheUser='www-data'
    if [ $HOST = 'XPS-13' ]; then
        # actual ... :(
        apacheUser=1001
    fi
    echo $apacheUser
}

function apachewith() {
    local SOME_USER=$1
    if ! userExists $SOME_USER; then
        echo "User ($SOME_USER) does not exists. I need one real user to go with apache(www-data)"
        echo "usage : apachewith REAL_USER <FILE>|<FOLDER> ..."
        return 1
    fi
    shift

    for FILE in "$@"; do
        if [ -f $FILE ]; then
            # a file
            sudo chown $(apacheUser):$SOME_USER $FILE
            sudo chmod g+rw $FILE
        elif [ -d $FILE ]; then
            # for a folder
            sudo chown -R $(apacheUser):$SOME_USER $FILE
            sudo chmod -R g+rw $FILE
        else
            echo "{$FILE} is not a valid element to change permissions on."
            continue
        fi
    done
    return 0
}

function apacheandme() {
    apachewith $USER "$@"
    return 0
}

function userExists() {
    id "$1" &>/dev/null
}

itsmine() {
    for FILE in "$@"; do
        if [ -f $FILE ]; then
            sudo chown $USER:$GROUP $FILE
        elif [ -d $FILE ]; then
            sudo chown -R $USER:$GROUP $FILE
        else
            echo "{$FILE} is not a valid element to chown "
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

function inArray() {
    local needle=$1
    shift
    local haystack=("$@")
    for i in $haystack; do
        if [[ $needle == $haystack[$i] ]]; then
            return 0
        fi
    done
    return 1
}
#first_array=(1 2 3)
#echo "---------------------------------"
#echo "should be pas cool"
#if inArray cat "${first_array[@]}"; then echo "cool"; else echo "pas cool"; fi
#echo "---------------------------------"
#echo "should be cool"
#if inArray 2 "${first_array[@]}"; then echo "cool"; else echo "pas cool"; fi
#echo "---------------------------------"

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
