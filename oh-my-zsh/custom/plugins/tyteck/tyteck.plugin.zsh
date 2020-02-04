alias zrc='source ~/.zshrc && echo "sourced !"'
alias please='sudo'
alias restart='please shutdown -r now'
alias reboot='restart'

export DASH_PATH="/home/www/dashboard.podmytube.com/"
export REDUCBOX_PATH="$HOME/Projects/reducbox"
export NGINX_PROXY_PATH="/var/opt/docker/nginx-proxy"
export MYSQL_SERVER_PATH="/home/docker/mysqlServer"


alias c='clear'
alias vtyteck='vim ~/dotfiles/oh-my-zsh/custom/plugins/tyteck/tyteck.plugin.zsh && zrc'
# docker & docker compose
alias dokbuild="docker-compose build"
alias dokconfig="docker-compose config"
alias dokcp="docker cp"
alias dokdown="docker-compose down --remove-orphans"
alias dokexec="docker exec -it"
alias dokexecu="dokexec --user $(id -u):$(id -g)"
alias doklog="docker logs -f"
alias doknames="docker ps --format '{{.Names}}'"
alias dokrm="docker container rm -f"
alias dokprune="docker container prune -f && docker image prune -f && docker network prune -f && docker volume prune -f"
alias dokrestart="docker-compose down --remove-orphans && docker-compose up -d"
alias dokrestartdev="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d"
alias dokrestartprod="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
alias doktus="docker ps -a"
alias dokup="docker-compose up -d"
alias dokupprod="docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

# shortcut to start containers
alias mysqlUp="cd $MYSQL_SERVER_PATH && dokup && cd -"
alias mysqlDown="cd $MYSQL_SERVER_PATH && dokdown && cd -"

alias nginxup="cd $NGINX_PROXY_PATH && dokup && cd -"
alias nginxdown="cd $NGINX_PROXY_PATH && dokdown && cd -"

alias reducdown="cd $REDUCBOX_PATH && dokdown && cd -"
alias dashdown="mysqlDown && cd $DASH_PATH && dokdown && cd -"

alias dashup="reducdown && mysqlUp && cd $DASH_PATH && dokup && cd -"
alias reducup="dashdown && cd $REDUCBOX_PATH && dokup && cd -"

# Symfony
alias sfc='php bin/console'

# Php
alias phpunit='./vendor/bin/phpunit --colors=always'

# biggest files
alias biggestFolders='du -a . | sort -n -r | head -n 10'
alias biggestFiles='du -Sh . | sort -rh | head -20'
alias spaceleft='df -h'
alias dirsize='du -sh'

# apt
alias fullapt='echo ==== APT-GET ==== && \
    sudo apt-get update -q -y && \
    sudo apt-get upgrade -q -y && \
    sudo apt-get autoclean -q -y && \
    sudo apt-get autoremove -q -y'
if hash ansible-playbook 2>/dev/null; then
    ansiblePlaybooksDirectory=$HOME/ansible-playbooks
    if [ -d $HOME/ansible-playbooks/ ]; then
        alias fullapt="ansible-playbook $ansiblePlaybooksDirectory/apt-upgrade.yml -i $ansiblePlaybooksDirectory/inventory/podmytube"
    else
        echo "ansible-playbook is installed but you have to clone git@github.com:tyteck/ansible-playbooks.git"
    fi
fi
alias shutdown="fullapt && please shutdown -h now"

# some core shortcuts
alias runcore='docker run --network nginx-proxy --name core.pmt --rm --volume /home/www/core.podmytube.com:/app --volume /var/log/pmt/error.log:/var/log/pmt/error.log core.pmt'
alias testcore='runcore phpunit --colors=always'
alias rundash='dokexec dashboard.podmytube.com'
alias testdash='dokexec dashboard.podmytube.com phpunit --colors=always'
alias testbox='dokexec reducbox phpunit --colors=always'

# default pathes cd shortcuts
alias cddash="cd /home/www/dashboard.podmytube.com/"
alias cddot="cd $HOME/dotfiles/"
alias cdreve="cd /home/www/reverse.podmytube.com/"
alias cdcore="cd /home/www/core.podmytube.com/"
alias cdplay="cd /home/docker/playlists.podmytube.com/"
alias cdpods="cd /home/docker/podcasts.podmytube.com/"
alias cdwww="cd /home/www/www.new.podmytube.com/"
alias frpod='cd /home/www/fr.podmytube.com/'
alias cdtyt='cd /home/www/www.tyteca.net/'
alias cdval='cd /home/www/valentin.tyteca.net/'

# default db shortcuts
alias dbroot='docker exec -it mysqlServer mysql --login-path=root'
alias dbpmt='docker exec -it mysqlServer mysql --login-path=pmt pmt'
alias dbpmtests='docker exec -it mysqlServer mysql --login-path=pmtests pmtests'

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
#                               	COMMODITIES
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

#
# message level
#
LEVEL_INFO=0
LEVEL_WARNING=1
LEVEL_ERROR=2
LEVEL_NOTICE=3
LEVEL_SUCCESS=4

function showMessage() {
    local message="$1"
    if [ -z "$message" ]; then message="no comments"; fi
    local level="$2"
    local color=$FG[231]
    local levelMessage=""
    case $level in
    $LEVEL_WARNING)
        color=$FG[011]
        levelMessage="Warning "
        ;;
    $LEVEL_SUCCESS)
        color=$FG[154]
        levelMessage="Success "
        ;;
    $LEVEL_ERROR)
        color=$FG[001]
        levelMessage="Error "
        ;;
    $LEVEL_NOTICE)
        color=$FG[002]
        levelMessage="Notice "
        ;;
    $LEVEL_INFO)
        color=$FG[004]
        levelMessage="Comment "
        ;;
    *)
        levelMessage=''
        ;;
    esac
    print -P ${color}${levelMessage}%{$reset_color%}- $message
}

function error() {
    local message="$1"
    showMessage "$message" $LEVEL_ERROR
}

function testShowMessage() {
    for level in {0..4}; do
        showMessage "test message" $level
    done
    error "Oops something went wrong <= this is a test message"
}

function apacheperms() {
    # giving to myself cause I'm still alone on my projects even in production mode
    groupToAllow=$USER
    for FILE in "$@"; do
        if [ -f $FILE ]; then
            sudo chown www-data:$groupToAllow $FILE
            sudo chmod g+w $FILE
        elif [ -d $FILE ]; then
            sudo chown -R www-data:$groupToAllow $FILE
            sudo chmod -R g+w $FILE
        else
            echo "{$FILE} is not a valid element to change permssions on."
            continue
        fi
    done
    return 0
}

# it s mine
# chowning files or folders to be mine.
# I need to OWN THEM ALL !!!!
# MUHAHAHAHAHAHAHAHAHA
itsmine() {
    for FILE in "$@"; do
        if [ -f $FILE ]; then
            sudo chown $USER:$USER $FILE
        elif [ -d $FILE ]; then
            sudo chown -R $USER:$USER $FILE
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
readVar() {
    VAR_NAME=$1
    FILE_NAME=$2
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
#                               	VSCODE
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

# import/export extensions from vscode
VSCodeExtFile="$HOME/dotfiles/vscode_extensions"

# this function is exporting list of installed VSCode extensions
exportVSCodeExtList() {
    echo $(code --list-extensions) >${VSCodeExtFile}
}

# this function is installing VSCode extensions according to one prefious export
importVSCodeExtList() {
    if [ -f $VSCodeExtFile ]; then
        echo "cleaning existing extensions"
        rm -rf $HOME/.vscode/extensions/*
        while read line; do
            for extensionToInstall in $line; do
                code --install-extension $extensionToInstall
            done
        done <"$VSCodeExtFile"
    else
        error "Le fichier contenant la liste des extensions est absent."
    fi
}

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
#                               	DOCKER
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

# get the ip address for one container
function dokip() {
    CONTAINER_NAME=$1
    docker inspect $CONTAINER_NAME --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

function dokips() {
    for CONTAINER_NAME in $(docker ps --format '{{.Names}}'); do
        echo $CONTAINER_NAME --- $(dokip $CONTAINER_NAME)
    done
}

function dokrmi() {
    IMAGE_NAME=$1
    docker rmi $(docker image ls --filter "reference=$IMAGE_NAME" -q)
}
