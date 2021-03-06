#!/bin/bash

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
# 							  	FUNCTIONS
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
if [ -f ~/dotfiles/.bash_functions ]; then
    . ~/dotfiles/.bash_functions
fi

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
# 							  CUSTOM PROMPT
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
export NODE_NAME=$(hostname)
if [ -f ~/dotfiles/.bash_prompt ]; then
    . ~/dotfiles/.bash_prompt
fi

export EDITOR=$(which vim)

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

# Directory navigation.
alias -- -='cd -'
alias ..='cd ..'
alias ..2='..; ..'
alias ..3='..2; ..'
alias ..4='..3; ..'
alias ..5='..4; ..'

# on debian ll is not uncommented within skel/.bashrc
alias ll='ls -alFh'
alias vbashrc="vim ~/.bashrc && source ~/.bashrc && echo 'bashrc sourced'"
alias sbashrc="source ~/.bashrc"
alias valiases="vim ~/dotfiles/.bash_aliases && source ~/dotfiles/.bash_aliases && echo 'bash_aliases sourced'"
alias phpext="php -i | grep extension_dir"
alias phpmods="php -m"
alias cls="clear"
alias please="sudo"
alias env="env|sort"

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
alias dokupfred="docker-compose -f docker-compose.fred.yml up -d"
alias dokupprod="docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

# some core shortcuts
alias runcore='docker run --network nginx-proxy --name core.pmt --rm --volume /home/www/core:/app --volume /var/log/pmt/error.log:/var/log/pmt/error.log core.pmt'
alias testcore='runcore phpunit --colors=always'

# Laravel
alias artisan='docker exec -it dash php artisan'
alias tinker='docker exec -it dash php artisan tinker'
alias tinkertest="echo '--- env=testing ---' && dokexec -it dash php artisan tinker --env=testing"

# Git
alias gtus='git status'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'

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
        comment "ansible-playbook is installed but you have to clone git@github.com:tyteck/ansible-playbooks.git"
    fi
fi
alias aptinstall="sudo apt-get install -y"

# curl
alias prettyjson="python -m json.tool"

# apache
alias apacheReload='sudo apache2ctl configtest && sudo apache2ctl graceful'
alias apacheStatus='sudo apache2ctl status'

# biggest files
alias biggestFolders='du -a . | sort -n -r | head -n 10'
alias biggestFiles='du -Sh . | sort -rh | head -20'
alias spaceleft='df -h'
alias dirsize='du -sh'

# some phpunit shortcuts
alias testcore='docker run --network nginx-proxy --name core.pmt --rm \
	--volume /home/www/core.podmytube.com/:/app \
	--volume /var/log/pmt/error.log:/var/log/pmt/error.log \
	core.pmt phpunit --colors always'

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

# common aliases
case $NODE_NAME in
frsopdreg3)
    export INTRA_CONTAINER_NAME="intranetlocal.sfmi.lan"
    export SFMI_CONTAINER_NAME="mysqlmaster"
    # Aliases that are used on micromania
    alias micro="cd /var/www/intranet/web/webintra && clear && ls -lsa sfmi/docs"
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
MSI-Laptop)
    # Aliases that are used elsewhere
    alias myadmin='cd /home/www/phpmyadmin.tyteca.net'
    # database access
    alias dbtyt='mysql --login-path=tyt tytecadotnet'
    alias dbpmtblog='mysql --login-path=pmtblog podmytubeFR'
    alias dbilec='mysql --login-path=lyceeIlec lyceeIlec'
    alias dbdevpod='mysql --login-path=devpod devPodmytube'
    alias dbval='mysql --login-path=valentin valentin'
    alias dbreve="mysql --login-path=reve $REV_DB"
    alias cdwww="cd /home/www/www.podmytube.com/"
    ;;
esac
alias getTables="docker exec $SFMI_CONTAINER_NAME /var/opt/getTables.sh"
