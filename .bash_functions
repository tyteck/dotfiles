#!/bin/bash

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
# 						    DEFAULT VARIABLES
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

#
# some colors
#
darkgreen="\e[32m"
red="\e[31m"
normal="\e[0m" # Text Reset

notice="\e[44m"
success="\e[48;5;22m"
warning="\e[30;48;5;166m"
error="\e[41m"

#
# message level
#
LEVEL_INFO=0
LEVEL_WARNING=1
LEVEL_ERROR=2
LEVEL_NOTICE=3
LEVEL_SUCCESS=4
LEVEL_COMMENT=5

VSCodeExtFile="$HOME/dotfiles/vscode_extensions"

# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
# 								FUNCTIONS
# °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸

gitown() {
	if [ -d ".git" ]; then
		git config user.email "frederick@tyteca.net"
		git config user.name "frederick tyteca"
		success "git config done"
	fi
}

gdelete() {
	BRANCH_TO_DELETE=$1
	if [ -z $BRANCH_TO_DELETE ]; then
		errorAndExit "To delete a branch we need a branch name ... don't you think so ?"
	fi
	git branch -d $BRANCH_TO_DELETE
	if [ "$?" != 0 ]; then
		errorAndExit "Branch {$BRANCH_TO_DELETE} deletion has failed"
	fi
	git push origin --delete $BRANCH_TO_DELETE
	if [ "$?" != 0 ]; then
		errorAndExit "Branch {$BRANCH_TO_DELETE} deletion has failed"
	fi
}

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
			if [ ! -f $1 ] && [ ! -d $1 ]; then
				echo "file/folder $1 doesn't exists"
			else
				commitFiles="$commitFiles $1"
			fi
			;;
		esac
		shift
	done
	if [[ -z ${commitFiles} ]]; then
		commitFiles='.'
	fi
	git commit -m "$commitMessage" $commitFiles && git push
	if [ "$?" != 0 ]; then
		error "Commit has failed"
	fi
}

# this function will restore one previously deleted (and committed file)
grestore() {
	FILEPATH_TO_RESTORE=$1
	git checkout $(git rev-list -n 1 HEAD -- "$FILEPATH_TO_RESTORE") -- "$FILEPATH_TO_RESTORE"
	if [ "$?" != 0 ]; then
		errorAndExit "Git restoring file $FILEPATH_TO_RESTORE has failed !"
	fi
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
			errorAndExit "{$FILE_OR_FOLDER_THAT_IS_MINE} is not a valid element to chown "
		fi
	done
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

# this function will display one title the way we can't miss it on term
title() {
	MESSAGE=$1
	format="\e[1;100m"
	echo -e "$format=== $MESSAGE ===$normal"
}

# Error (white on red) will precede the message
error() {
	message=$1
	showMessage "$message" $LEVEL_ERROR
}

errorAndExit() {
	error "$1"
	exit 1
}

warning() {
	message=$1
	showMessage "$message" $LEVEL_WARNING
}

success() {
	message=$1
	showMessage "$message" $LEVEL_SUCCESS
}

notice() {
	message=$1
	showMessage "$message" $LEVEL_NOTICE
}

comment() {
	message=$1
	showMessage "$message" $LEVEL_COMMENT
}

verbose() {
	message=$1
	[ "${VERBOSE}" -eq "${TRUE}" ] && comment "$message"
}

showMessage() {
	message=$1
	level=$2
	color=""
	levelMessage=""
	case $level in
	$LEVEL_WARNING*)
		color=$warning
		levelMessage="Warning"
		;;
	$LEVEL_SUCCESS*)
		color=$success
		levelMessage="Success"
		;;
	$LEVEL_ERROR*)
		color=$error
		levelMessage="Error"
		;;
	$LEVEL_NOTICE*)
		color=$notice
		levelMessage="Notice"
		;;
	$LEVEL_COMMENT*)
		color=$darkgreen
		levelMessage="Comment"
		;;
	*)
		color=$darkgreen
		levelMessage="Notice"
		;;
	esac
	echo -e "${color}${levelMessage}${normal} : ${message}"
}

# tests
comment "lorem ipsum"
notice "lorem ipsum"
warning "lorem ipsum"
error "lorem ipsum"
success "lorem ipsum"

# get the ip address for one container
dokip() {
	CONTAINER_NAME=$1
	docker inspect $CONTAINER_NAME --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

dokips() {
	for CONTAINER_NAME in $(docker ps --format '{{.Names}}'); do
		echo $CONTAINER_NAME --- $(dokip $CONTAINER_NAME)
	done
}

dokrmi() {
	IMAGE_NAME=$1
	docker rmi $(docker image ls --filter "reference=$IMAGE_NAME" -q)
}

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
