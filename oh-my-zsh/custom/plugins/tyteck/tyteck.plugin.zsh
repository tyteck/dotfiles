alias zrc='source ~/.zshrc'
alias please='sudo'

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

