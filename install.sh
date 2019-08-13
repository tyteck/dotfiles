#!/bin/bash
# Maintainer : frederick tyteca <frederick@tyteca.net>
# This script only goal is to prepare my dev environment
# It is copying some bash configuration files 
# - .bashrc
# - .bash_aliases
# - .vimrc
# and some configuration file for VScode as well.
#
SCRIPT_DIR=$(dirname ${0})
SCRIPT_NAME=$(basename ${0})

if [ -f .bash_functions ];then
    . .bash_functions
fi

#
# Default values
#
TRUE=0
FALSE=1
VERBOSE=${FALSE}
INFO=0
WARNING=1
ERROR=2


waitForUser() {
    message=$1
    while true; do
        read -p "$message" yesOrNo
        case $yesOrNo in
        [Yy]*)
            break
            ;;
        [Nn]*)
            exit
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

#
# Files I will replace with the dotfiles
#
filesToReplace="$HOME/.bashrc $HOME/.bash_aliases $HOME/.vimrc $HOME/.config/Code/User/settings.json"

if [ -z $HOME ];then
    errorAndExit "Environment variable HOME not set, I prefer to stop !"
fi

#
# Getting params
#
while [ $# -gt 0 ]; do
	case $1 in
		'-?' | '-h' | '--help')
			usage
			;;
		'-v' | '--verbose')
			VERBOSE=${TRUE}
			;;
	esac
	shift
done

#
# Processing config files 
#
for fileToReplace in $filesToReplace; do
    file=$(basename $fileToReplace)
    dir=$(dirname $fileToReplace)
    
    sourceFile="$HOME/dotfiles/$file"
    backupFile="$fileToReplace.back"

    #
    # Creating target directory
    #
    if [ ! -d $dir ];then
        verbose "Creating directory ${dir}"
        mkdir -p $dir
    fi

    if [ -L $backupFile ]; then
        #
        # if backup file already exists AND is one symlink => removing
        #
        verbose "Removing symlink ${backupFile}"
        unlink $backupFile
    elif [ -f $backupFile ]; then
        #
        # if backup file already exists AND is one regular file => removing
        #
        waitForUser "Backup file $backupFile already exists. Do you agree to overwrite it ? [y/N] : "
        verbose "Removing file ${backupFile}"
        unlink $backupFile
    fi

    if [ -L $fileToReplace ]; then
        #
        # if file to replace already exists AND is one symlink => removing
        #
        verbose "Removing symlink ${fileToReplace}"
        unlink $fileToReplace
    elif [ -f $fileToReplace ]; then
        #
        # if file to replace already exists AND is one regulaar file => moving
        #
        verbose "backuping file ${fileToReplace} => ${backupFile}"
        mv $fileToReplace $backupFile
    fi 
    verbose "Creating symlink to ${sourceFile}"
    ln -s $sourceFile $fileToReplace
done
exit 0
