alias zrc='source ~/.zshrc && echo "sourced !"'
alias please='sudo'
alias restart='please shutdown -r now'
alias reboot='restart'

PROJECTS_PATH="$HOME/Projects"
DASH_PATH="$PROJECTS_PATH/dashboard.podmytube.com"
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

alias c='clear'
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

alias wepadelup="reducdown && dashdown && cd $WEPADEL_PATH && gpull && dokup && code ."
alias wepadeldown="cd $WEPADEL_PATH && dokdown && cd -"

alias nginxup="cd $NGINX_PROXY_PATH && dokup && gpull && cd -"
alias nginxdown="cd $NGINX_PROXY_PATH && dokdown && cd -"

alias gpuup="reducdown && dashdown && mysqlUp && phpmyadminUp && cd $GPU_PATH && gpull && dokup && code ."
alias gpudown="cd $GPU_PATH && dokdown && cd -"

alias dashup="reducdown && mysqlUp && phpmyadminUp && cd $DASH_PATH && gpull && dokup && code ."
alias dashdown="cd $DASH_PATH && dokdown && cd -"

alias reducdown="cd $REDUCBOX_PATH && docker-compose down && cd -"
alias reducup="dashdown && mysqlDown && phpmyadminDown && cd $REDUCBOX_PATH && gpull && dokup && code ."
alias dashexec="docker exec -it --user www-data dashboard.podmytube.com"

# Symfony
alias sfc='php bin/console'

# Php
alias phpunit='./vendor/bin/phpunit --colors=always'

# npm
alias upgradeNpm='sudo npm install -g npm'

# Composer
alias cdu='composer dumpautoload'
alias compoUpdate='composer update --ignore-platform-reqs'
alias compoInstall="composer install --ignore-platform-reqs"
alias compoRequire="composer require --ignore-platform-reqs"
alias compoRemove="composer remove --ignore-platform-reqs"

# linux
alias editHosts='sudo vim /etc/hosts'
alias biggestFolders='du -a . | sort -n -r | head -n 10'
alias biggestFiles='du -Sh . | sort -rh | head -20'
alias dir='du -hs * | sort -h'

# apt
alias fullapt='sudo apt-get update -q -y && \
    sudo apt-get upgrade -q -y && \
    sudo apt-get autoclean -q -y && \
    sudo apt-get autoremove -q -y'

case $(uname -n) in
"msi-laptop")
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

# some core shortcuts
alias runcore='docker run --network nginx-proxy --name core.pmt --rm --volume /usr/local/bin/youtube-dl:/usr/local/bin/youtube-dl --volume /home/www/core.podmytube.com:/app --volume /var/log/pmt/error.log:/var/log/pmt/error.log core.pmt'
alias ngrokdash='screen -d -m ngrok http -subdomain=dashpod -region eu 80'

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
    fileToEmpty=$1
    if [ -z $fileToEmpty ]; then
        echo "You should specify the file path you want to empty"
        return 1
    fi
    : >$fileToEmpty
    echo "$fileToEmpty is now empty"
    return 0
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
            echo "{$ITEM} is not a valid element to change permssions on."
            continue
        fi
    done
    return 0
}

function apachewith() {
    SOME_USER=$1
    if ! userExists $SOME_USER; then
        echo "User ($SOME_USER) does not exists. I need one real user to go with apache(www-data)"
        echo "usage : apachewith REAL_USER <FILE>|<FOLDER> ..."
        return 1
    fi
    shift
    for FILE in "$@"; do
        if [ -f $FILE ]; then
            # a file
            sudo chown www-data:$SOME_USER $FILE
            sudo chmod g+rw $FILE
        elif [ -d $FILE ]; then
            # for a folder
            sudo chown -R www-data:$SOME_USER $FILE
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

# it s mine
# chowning files or folders to be mine.
# I need to OWN THEM ALL !!!!
# MUHAHAHAHAHAHAHAHAHA
if [ -z $GROUP ]; then
    export GROUP=staff
fi

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
