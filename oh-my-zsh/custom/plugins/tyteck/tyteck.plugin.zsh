alias zrc='source ~/.zshrc && echo "sourced !"'
alias please='sudo'

alias c='clear'
alias vtyteck='vim ~/dotfiles/oh-my-zsh/custom/plugins/tyteck/tyteck.plugin.zsh && zrc'
# docker & docker compose
alias dokbuild="docker-compose build"
alias dokconfig="docker-compose config"
alias dokcp="docker cp"
alias dokdown="docker-compose down --remove-orphans"
alias dokexec="docker exec -it"
alias dokexecu="dokexec --user $(id -u):$(id -g)"
alias doklog="docker logs"
alias doknames="docker ps --format '{{.Names}}'"
alias dokrm="docker container rm -f"
alias dokprune="docker container prune -f && docker image prune -f && docker network prune -f && docker volume prune -f"
alias dokrestart="docker-compose down --remove-orphans && docker-compose up -d"
alias dokrestartprod="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
alias doktus="docker ps -a"
alias dokup="docker-compose up -d"
alias dokupprod="docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

# Symfony
alias sfc='php bin/console'

# Laravel
alias dashtisan='dokexec --user $(id -u):$(id -g) dash php artisan'
alias dashtinker='dashtisan tinker'
alias dashtinkertest="echo '--- env=testing ---' && dashtisan tinker --env=testing"

alias shartisan='dokexec --user $(id -u):$(id -g) share php artisan'
alias shartinker='shartisan tinker'
alias shartinkertest="echo '--- env=testing ---' && shartisan tinker --env=testing"

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
        comment "ansible-playbook is installed but you have to clone git@github.com:tyteck/ansible-playbooks.git"
    fi
fi


# some phpunit shortcuts
alias testcore='docker run --network nginx-proxy --name core.pmt --rm \
	--volume /home/www/core.podmytube.com/:/app \
	--volume /var/log/pmt/error.log:/var/log/pmt/error.log \
	core.pmt phpunit --colors=always'

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

# this function will display one title the way we can't miss it on term
# function title() {
# 	MESSAGE=$1
# 	format="\e[1;100m"
# 	echo -e "$format=== $MESSAGE ===\e[0m"
# }
# 
# # Error (white on red) will precede the message
# error() {
# 	message=$1
# 	showMessage "$message" $LEVEL_ERROR
# }
# 
# warning() {
# 	message="$1"
# 	showMessage "$message" $LEVEL_WARNING
# }
# 
# success() {
# 	message="$1"
# 	showMessage "$message" $LEVEL_SUCCESS
# }
# 
# notice() {
# 	message="$1"
# 	showMessage "$message" $LEVEL_NOTICE
# }
# 
# comment() {
# 	message="$1"
# 	showMessage "$message" $LEVEL_COMMENT
# }
# 
# verbose() {
# 	message="$1"
# 	[ "${VERBOSE}" -eq "${TRUE}" ] && comment "$message"
# }


#
# some colors
#
#darkgreen="\e[32m"
#red="\e[31m"
#notice="\e[44m"
#success="\e[48;5;22m"
#warning="\e[30;48;5;166m"
#error="\e[41m"

#
# message level
#
LEVEL_INFO=0
LEVEL_WARNING=1
LEVEL_ERROR=2
LEVEL_NOTICE=3
LEVEL_SUCCESS=4
LEVEL_COMMENT=5

function showMessage() {
    local message="$1"
    if [ -z "$message" ]; then message="no comments"; fi
    local level="$2"
    local color=""
    local levelMessage=""
    case $level in
#   $LEVEL_WARNING)
#       color=$warning
#       levelMessage="Warning"
#       ;;
#   $LEVEL_SUCCESS)
#       color=$success
#       levelMessage="Success"
#       ;;
#   $LEVEL_ERROR)
#       color=$error
#       levelMessage="Error"
#       ;;
#   $LEVEL_NOTICE)
#       color=$notice
#       levelMessage="Notice"
#       ;;
#   $LEVEL_COMMENT)
#       color="\e[32m"
#       levelMessage="Comment"
#       ;;
    *)
        print -P '%B%F{green}Notice%f%b'
        ;;
    esac
}


# it s mine
# chowning files or folders to be mine.
# I need to OWN THEM ALL !!!!
# MUHAHAHAHAHAHAHAHAHA
itsmine() {
	for FILE_OR_FOLDER_THAT_IS_MINE in "$@"; do
		if [ -f $FILE_OR_FOLDER_THAT_IS_MINE ]; then
			sudo chown $USER:$USER $FILE_OR_FOLDER_THAT_IS_MINE
		elif [ -d $FILE_OR_FOLDER_THAT_IS_MINE ]; then
			sudo chown -R $USER:$USER $FILE_OR_FOLDER_THAT_IS_MINE
		else
			error "{$FILE_OR_FOLDER_THAT_IS_MINE} is not a valid element to chown "
			return 1
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
	IFS="=" read -ra VAR <<<"$VAR"
	echo ${VAR[1]}
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

