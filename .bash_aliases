#!/bin/bash
if [ -f ~/dotfiles/.creds ]; then
	. ~/dotfiles/.creds
fi

export NODE_NAME=$(hostname)
export EDITOR="/usr/bin/vim"

if [ -d ~/sbin ]; then
	PATH="${PATH}:~/sbin"
fi

# history tricks
export HISTSIZE=100000               # big big history
export HISTFILESIZE=100000           # big big history
export HISTTIMEFORMAT="%d/%m/%y %T " # history formatting
shopt -s histappend                  # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# on debian ll is not uncommented within skel/.bashrc
alias ll='ls -alFh'
alias vbashrc="vim ~/.bashrc && source ~/.bashrc && echo 'bashrc sourced'"
alias sbashrc="source ~/.bashrc"
alias valiases="vim ~/dotfiles/.bash_aliases && source ~/dotfiles/.bash_aliases && echo 'bash_aliases sourced'"
alias phpext="php -i | grep extension_dir"
alias phpmods="php -m"
alias cls="clear"
alias env="env|sort"

# Laravel
alias artisan='php artisan'
alias migrate='php artisan migrate'
alias migtus='php artisan migrate:status'
alias artseed='php artisan db:seed'
alias sf='php bin/console'
alias tinker='artisan tinker'
alias tinkertest="echo '=== env=testing ===' && artisan tinker --env=testing"

# Git
alias gtus='git status'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'

# docker & docker compose
alias dokbuild="docker-compose build"
alias dokconfig="docker-compose config"
alias dokdown="docker-compose down"
alias dokexec="docker exec -it "
alias doklog="docker logs"
alias doknames="docker ps --format '{{.Names}}'" 
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

# default pathes cd shortcuts
alias cddash="cd /home/www/dashboard.podmytube.com/"
alias cdreve="cd /home/www/reverse.podmytube.com/"
alias cdcore="cd /home/www/core.podmytube.com/"
alias cdreve="cd /home/www/reverse.podmytube.com/"
alias cdplay="cd /home/docker/playlists.podmytube.com/"
alias cdpods="cd /home/docker/podcasts.podmytube.com/"
alias cdwww="cd /home/www/www.new.podmytube.com/www"
alias cdforest="cd /home/docker/forest"
alias frpod='cd /home/www/fr.podmytube.com/'
alias cdtyt='cd /home/www/www.tyteca.net/'
alias cdval='cd /home/www/valentin.tyteca.net/'
alias cdlyc='cd /home/www/www.lycee-ilec.fr'

# default db shortcuts
alias dbroot='mysql --login-path=root'
alias dbpmt='mysql --login-path=pmt pmt'
alias dbpmtests='mysql --login-path=pmtests pmtests'

# common aliases
export PMTDB_HOST="mysqlServer"
export PMTDB_NAME="pmt"
export PMTESTSDB_NAME="pmtests"
export REV_DB="rev"
export REV_HOST="revdb"

case $NODE_NAME in
frsopdreg3)
	export INTRA_CONTAINER_NAME="intra"
	export SFMI_CONTAINER_NAME="mysqlmaster"
	# Aliases that are used on micromania
	alias db="docker exec -it mysqlmaster mysql $MYSQLMASTER_CREDS sfmi"
	alias castest="dokexec $INTRA_CONTAINER_NAME phpunit --colors=auto ./sfmi/docs/stats/loots/ventes_par_casier/tests/"
	alias micro="cd /var/www/intranet/ && clear && ls -lsa web/sfmi/docs"
	alias cdcore="cd /home/www/core"
	alias cdreve="cd /home/www/reve"
	alias cddash="cd /home/www/dash"
	alias cdwww="cd /home/www/web/www"
	alias cdplay="cd /home/www/play"
	alias cdpods="cd /home/www/pods"
	;;
intranetpreprod)
	# Aliases that are used on micromania
	alias db="mysql --login-path=sfmiread sfmi"
	alias micro="cd /usr/local/web"
	;;
FRSOPGIT)
	export INTRA_CONTAINER_NAME="intranetrec.sfmi.lan"
	export SFMI_CONTAINER_NAME="mysql"
	;;
ns3071385)
	alias cdmp3="cd /home/www/mp3.podmytube.com/www"
	alias cdpod="cd /home/www/podcasts.podmytube.com/www"
	alias cdplay="cd /home/www/playlists.podmytube.com/www"
	alias cdthumbs="cd /home/www/thumbs.podmytube.com/www"
	alias devmp3="cd /home/www/mp3.dev.podmytube.com/www"
	;;
vps591114)
	alias cdwww="cd /home/www/www.new.podmytube.com"
	;;
MSI-Laptop)
	export REV_DB="reverse"
	export REV_HOST="localhost"
	# Aliases that are used elsewhere
	alias myadmin='cd /home/www/phpmyadmin.tyteca.net'
	# database access
	alias dbtyt='mysql --login-path=tyt tytecadotnet'
	alias dbpmtblog='mysql --login-path=pmtblog podmytubeFR'
	alias dbilec='mysql --login-path=lyceeIlec lyceeIlec'
	alias dbdevpod='mysql --login-path=devpod devPodmytube'
	alias dbval='mysql --login-path=valentin valentin'
	alias dbreve="mysql --login-path=reve $REV_DB"
	;;
esac
alias getTables="docker exec $INTRA_CONTAINER_NAME /var/opt/getTables.sh --host $SFMI_CONTAINER_NAME"

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
# 							  CUSTOM PROMPT
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
if [ -f ~/dotfiles/.bash_prompt ]; then
	. ~/dotfiles/.bash_prompt
fi

if [ -f ~/dotfiles/.bash_functions ]; then
	. ~/dotfiles/.bash_functions
fi
