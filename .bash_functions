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
