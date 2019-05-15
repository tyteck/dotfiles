#!/bin/bash

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
# 								FUNCTIONS
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

# Git commit then push in one command
# if no file is specified the . folder is commit then pushed
gmit() {
	commitFiles=""
	while [ $# -gt 0 ]; do
		case $1 in
			'-?' | '-h' | '--help')
				usage
				;;
			'-m')
				commitMessage=$2
				shift
				;;
			*)
				if [ ! -f $1 ] && [ ! -d $1 ];then
					echo "file/folder $1 doesn't exists"				
				else 
					commitFiles="$commitFiles $1"
				fi
				;;
		esac
		shift
	done
	if  [[ -z ${commitFiles} ]]; then
		commitFiles='.'
	fi
	git commit -m "$commitMessage" $commitFiles && git push
	if [ "$?" != 0 ]; then
		echo "Commit has failed !"
	fi 
}

# it s mine
# chowning files or folders to be mine. 
# I need to OWN THEM ALL !!!!
# MUHAHAHAHAHAHAHAHAHA
itsmine(){
	for FILE_OR_FOLDER_THAT_IS_MINE in "$@";do
		if [ -f $FILE_OR_FOLDER_THAT_IS_MINE ];then
			sudo chown $USER:$USER $FILE_OR_FOLDER_THAT_IS_MINE
		elif [ -d $FILE_OR_FOLDER_THAT_IS_MINE ];then
			sudo chown -R $USER:$USER $FILE_OR_FOLDER_THAT_IS_MINE
		else 
			error "{$FILE_OR_FOLDER_THAT_IS_MINE} is not a valid element to chown "
		fi
	done
}

# this function will display one title the way we can't miss it on term
title() {
	MESSAGE=$1
	format="\e[1;100m"
	normal="\e[0m"
	echo -e "$format=== $MESSAGE ===$normal"
}

# Error (white on red) will precede the message
error() {
	MESSAGE=$1
	format="\e[1;41m"
	normal="\e[0m"
	echo -e "${format}Error :$normal $MESSAGE"
}

# Warning (white on orange) will precede the message
warning() {
	MESSAGE=$1
	format="\e[30;48;5;166m"
	normal="\e[0m"
	echo -e "${format}Warning :$normal $MESSAGE"
}

# success message
success() {
	MESSAGE=$1
	format="\e[30;48;5;82m"
	normal="\e[0m"
	echo -e "${format}Success :$normal $MESSAGE"
}

# single notice
notice() {
	MESSAGE=$1
	format="\e[1;44m"
	normal="\e[0m"
	echo -e "${format}Notice :$normal $MESSAGE"
}

# get the ip address for one container
dokip(){
	CONTAINER_NAME=$1
	docker inspect $CONTAINER_NAME --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

dokips(){
	for CONTAINER_NAME in $(docker ps --format '{{.Names}}');do
		echo $CONTAINER_NAME --- $(dokip $CONTAINER_NAME)
	done
}

# this function is exporting list of installed VSCode extensions
exportVSCodeExtList() {
	VSCodeExtFile="$HOME/dotfiles/vscode_extensions"
	code --list-extensions > $VSCodeExtFile
}

# this function is installing VSCode extensions according to one prefious export
importVSCodeExtList() {
	VSCodeExtFile="$HOME/dotfiles/vscode_extensions"
	if [ -f $VSCodeExtFile ];then
		echo "cleaning existing extensions"
		rm -rf $HOME/.vscode/extensions/*
		while IFS= read -r extensionToInstall
		do
			code --install-extension $extensionToInstall
		done < "$VSCodeExtFile"
	else
		error "Le fichier contenant la liste des extensions est absent."
	fi
}


