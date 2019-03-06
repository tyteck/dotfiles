#!/bin/bash
if [ -f ~/dotfiles/.creds ]; then
    . ~/dotfiles/.creds
else
	echo 
	echo '°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸'
	echo "~/dotfiles/.creds not set"
	echo '°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸'
	echo
fi


export NODE_NAME=`hostname`
export EDITOR="/usr/bin/vim"

if [ -d ~/sbin ]; then
    PATH="${PATH}:~/sbin"
fi


# history tricks
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
export HISTTIMEFORMAT="%d/%m/%y %T "	 # history formatting
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


alias vbashrc="vim ~/.bashrc && source ~/.bashrc && echo 'bashrc sourced'"
alias sbashrc="source ~/.bashrc"
alias valiases="vim ~/dotfiles/.bash_aliases && source ~/dotfiles/.bash_aliases && echo 'bash_aliases sourced'"
alias phpext="php -i | grep extension_dir"
alias phpmods="php -m"
alias cls="clear"

# Laravel
alias artisan='php artisan'
alias migrate='php artisan migrate'
alias migtus='php artisan migrate:status'
alias artseed='php artisan db:seed'
alias sf='php bin/console'
alias tinker='artisan tinker'

# Git
alias gtus='git status'
alias gdiff='git diff'
alias gmit='git commit -m '
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'

# docker & docker compose
alias dokbuild="docker-compose build"
alias dokdown="docker-compose down"
alias dokexec="docker exec -it "
alias doklog="docker logs"
alias dokprune="docker container prune -f && docker image prune -f && docker network prune -f && docker volume prune -f"
alias dokrestart="docker-compose down && docker-compose up -d"
alias doktus="docker ps -a"
alias dokup="docker-compose up -d"

# apt
alias aptinstall="sudo apt install -y"
alias fullapt='echo ==== APT-GET ==== && \
	sudo apt-get upgrade -q -y && \
	sudo apt-get upgrade -q -y && \
	sudo apt-get autoclean -q -y && \
	sudo apt-get autoremove -q -y'

# curl
alias prettyjson="python -m json.tool"

# apache
alias apacheReload='sudo apache2ctl configtest && sudo apache2ctl graceful'
alias apacheStatus='sudo apache2ctl status'

# biggest files
alias biggestFolders='du -a . | sort -n -r | head -n 10'
alias biggestFiles='du -Sh . | sort -rh | head -20'
alias spaceleft='df -h'

# common aliases
alias dbroot='mysql --login-path=root'
case $NODE_NAME in
	frsopdreg3)
		export PMT_DB="pmt"
		export REV_DB="rev"
		export INTRA_CONTAINER_NAME="intramania"
		export SFMI_CONTAINER_NAME="mysqlmaster"
		# Aliases that are used on micromania
		alias db="docker exec -it mysqlmaster mysql $MYSQLMASTER_CREDS sfmi"
		alias micro="cd /home/docker/intranet/src/web && clear && ls -lsa sfmi/docs" 
		alias cdcore="cd /home/www/core"
		alias cdreve="cd /home/www/reve"
		alias cddash="cd /home/www/dash"
		alias cdwww="cd /home/www/web/www"
		;;
	intranetpreprod)
		# Aliases that are used on micromania
		alias db="mysql --login-path=sfmiread"
		alias micro="cd /usr/local/web" 
		;;
	FRSOPGIT)
		export INTRA_CONTAINER_NAME="intranetrec.sfmi.lan"
		export SFMI_CONTAINER_NAME="mysql"
		;;
	ns3071385)
		alias cdmp3="cd /home/www/mp3.podmytube.com/www"
		alias devmp3="cd /home/www/mp3.dev.podmytube.com/www"
		;;
	vps256025.ovh.net)
		alias cdcore="cd /home/www/www.podmytube.com/"
		;;
	*)
		export PMT_DB="podmytube"
		export REV_DB="reverse"
		# Aliases that are used elsewhere
		# pathes
		alias cddash="cd /home/www/dashboard.podmytube.com/"
		alias cdreve="cd /home/www/reverse.podmytube.com/"
		alias cdcore="cd /home/www/core.podmytube.com/"
		alias cdreve="cd /home/www/reverse.podmytube.com/"
		alias cdwww="cd /home/www/www.new.podmytube.com/www"
		alias frpod='cd /home/www/fr.podmytube.com/'
		alias cdtyt='cd /home/www/www.tyteca.net/'
		alias cdval='cd /home/www/valentin.tyteca.net/'
		alias cdlyc='cd /home/www/www.lycee-ilec.fr'
		alias myadmin='cd /home/www/phpmyadmin.tyteca.net'

		# database access
		alias dbtyt='mysql --login-path=tyt tytecadotnet'
		alias dbpmtblog='mysql --login-path=pmtblog podmytubeFR'
		alias dbilec='mysql --login-path=lyceeIlec lyceeIlec'
		alias dbdevpod='mysql --login-path=devpod devPodmytube'
		alias dbval='mysql --login-path=valentin valentin'
		;;
esac
alias dbpmt="mysql --login-path=pmt $PMT_DB"
alias dbreve="mysql --login-path=reve $REV_DB"
alias getTables="docker exec $INTRA_CONTAINER_NAME /var/opt/getTables.sh --host $SFMI_CONTAINER_NAME_"

# Add custom prompt
if [ -f ~/dotfiles/.bash_prompt ]; then
    . ~/dotfiles/.bash_prompt
fi
