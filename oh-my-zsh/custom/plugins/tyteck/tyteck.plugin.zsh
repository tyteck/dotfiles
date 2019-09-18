alias zrc='source ~/.zshrc'
alias please='sudo'

# docker & docker compose
alias dokbuild="docker-compose build"
alias dokconfig="docker-compose config"
alias dokdown="docker-compose down"
alias dokexec="docker exec -it"
alias dokexecu="docker exec --user $(id -u):$(id -g) -it"
alias doklog="docker logs"
alias doknames="docker ps --format '{{.Names}}'"
alias dokrm="docker container rm -f"
alias dokprune="docker container prune -f && docker image prune -f && docker network prune -f && docker volume prune -f"
alias dokrestart="docker-compose down && docker-compose up -d"
alias dokrestartprod="docker-compose down && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
alias doktus="docker ps -a"
alias dokup="docker-compose up -d"
alias dokupprod="docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

# Laravel
alias artisan='docker exec -it dash php artisan'
alias tinker='docker exec -it dash php artisan tinker'
alias tinkertest="echo '--- env=testing ---' && dokexec -it dash php artisan tinker --env=testing"

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
alias dbroot='mysql --login-path=root'
alias dbpmt='mysql --login-path=pmt pmt'
alias dbpmtests='mysql --login-path=pmtests pmtests'



# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
#                               	COMMODITIES
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

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

