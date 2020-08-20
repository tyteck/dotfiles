alias zrc='source ~/.zshrc && echo "sourced !"'
alias please='sudo'
alias restart='please shutdown -r now'
alias reboot='restart'

export DASH_PATH="$HOME/Projects/dashboard.podmytube.com"
export REDUCBOX_PATH="$HOME/Projects/reducbox"
export NGINX_PROXY_PATH="/var/opt/docker/nginx-proxy"
export MYSQL_SERVER_PATH="$HOME/Projects/mysqlserver"
export PHPMYADMIN_PATH="$HOME/Projects/phpmyadmin"

# these 2 variables are used during docker container building.
# one user (dockeruser) is created using my UID and GID
# so when I'm doing an action into the container with this user
# perms IN container are dockeruser
# perms IN host are mine
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

alias c='clear'
alias vtyteck='vim ~/dotfiles/oh-my-zsh/custom/plugins/tyteck/tyteck.plugin.zsh && zrc'
# docker & docker compose
alias dokbuild="docker-compose build"
alias dokconfig="docker-compose config"
alias dokcp="docker cp"
alias dokdown="docker-compose down --remove-orphans"
alias dokexec="docker exec -it --user $USER_ID"
alias dokexecroot="docker exec -it"
alias doklog="docker logs -f"
alias doknames="docker ps --format '{{.Names}}'"
alias dokrm="docker container rm -f"
alias dokprune="docker system prune -f"
alias dokrestart="docker-compose down --remove-orphans && docker-compose up -d"
alias dokrestartdev="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d"
alias doktus="docker ps -a"
alias dokup="docker-compose up -d"
alias dokupprod="docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

# shortcut to start containers
alias mysqlUp="cd $MYSQL_SERVER_PATH && dokup && cd -"
alias mysqlDown="cd $MYSQL_SERVER_PATH && dokdown && cd -"

alias phpmyadminUp="cd $PHPMYADMIN_PATH && dokup && cd -"
alias phpmyadminDown="cd $PHPMYADMIN_PATH && dokdown && cd -"

alias nginxup="cd $NGINX_PROXY_PATH && dokup && cd -"
alias nginxdown="cd $NGINX_PROXY_PATH && dokdown && cd -"

alias reducdown="cd $REDUCBOX_PATH && dokdown && cd -"
alias dashdown="mysqlDown && phpmyadminDown && cd $DASH_PATH && dokdown && cd -"

alias dashup="reducdown && mysqlUp && phpmyadminUp && cd $DASH_PATH && dokup && cd -"
alias reducup="dashdown && cd $REDUCBOX_PATH && dokup && cd -"

# Symfony
alias sfc='php bin/console'

# Php
alias phpunit='./vendor/bin/phpunit --colors=always'

# biggest files
alias biggestFolders='du -a . | sort -n -r | head -n 10'
alias biggestFiles='du -Sh . | sort -rh | head -20'
alias dir='du -hs * | sort -h'

# apt
alias fullapt='sudo apt-get update -q -y && \
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

case $(uname -n) in
"msi-laptop")
    alias shutdown="fullapt && please shutdown -h now"
    ;;
*)
    alias shutdown="please shutdown -h now"
    ;;
esac

# some core shortcuts
alias runcore='docker run --network nginx-proxy --name core.pmt --rm --volume /usr/local/bin/youtube-dl:/usr/local/bin/youtube-dl --volume /home/www/core.podmytube.com:/app --volume /var/log/pmt/error.log:/var/log/pmt/error.log core.pmt'
alias ngrokdash='screen -d -m ngrok http -subdomain=dashpod -region eu 80'

# default db shortcuts
alias dbroot='docker exec -it mysqlServer mysql --login-path=root'
alias dbpmt='docker exec -it mysqlServer mysql --login-path=pmt pmt'

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
            sudo chmod g+rw $FILE
        elif [ -d $FILE ]; then
            sudo chown -R www-data:$groupToAllow $FILE
            sudo chmod -R g+rw $FILE
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
