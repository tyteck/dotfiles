#!/bin/bash
# Maintainer : frederick tyteca <frederick@tyteca.net>
# This script only goal is to prepare my dev environment
# It is copying some bash configuration files
# - .bashrc
# - .bash_aliases
# - .vimrc
# - settings.json (VS Code)
# and some configuration file for VScode as well.
#
SCRIPT_DIR=$(dirname ${0})
SCRIPT_NAME=$(basename ${0})

if [ -f .bash_functions ]; then
    . .bash_functions
fi

function backup(){
    local itemToBackup=$1
    local backupItem="${itemToBackup}.bak"
    verbose "backuping item ${itemToBackup} => ${backupItem}"
    mv $itemToBackup $backupItem
    if [ $? != 0 ]; then
        error "Backup from ${itemToBackup} to ${backupItem} has failed"
        return 1
    fi
    return 0
}

function removeExistingFile() {
    local fileToRemove=$1
    local fileToRemoveType=""
    if [ ! -f $fileToRemove ]; then
        return 0
    fi
    if [ -L $fileToRemove ]; then
        fileToRemoveType="symlink"
    else
        fileToRemoveType="file"
    fi
    verbose "Removing ${fileToRemoveType} ${fileToRemove}"
    unlink $fileToRemove
    if [ $? != 0 ]; then
        error "Removing ${fileToRemove} has failed"
        return 1
    fi
    return 0
}

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

if [ -z $HOME ]; then
    error "Environment variable HOME not set, I prefer to stop !"
    return 1
fi

#
# Files I will replace with symlinks to their dotfiles equivalent.
#
dotfiles="$HOME/dotfiles"
declare -A itemsToReplace
itemsToReplace["$HOME/.config/terminator"]="$dotfiles/terminator"
itemsToReplace["$HOME/.bashrc"]="$dotfiles/.bashrc"
itemsToReplace["$HOME/.bash_aliases"]="$dotfiles/.bash_aliases"
itemsToReplace["$HOME/.vimrc"]="$dotfiles/.vimrc"
itemsToReplace["$HOME/.config/Code/User/settings.json"]="$dotfiles/code/settings.json"
itemsToReplace["$HOME/.config/Code/User/keybindings.json"]="$dotfiles/code/keybindings.json"
itemsToReplace["$HOME/.config/Code/User/snippets"]="$dotfiles/code/snippets"

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


for itemToReplace in "${!itemsToReplace[@]}"; do 
    #
    # itemToReplace = the original item
    # targetItem = the item in the git dotfiles
    #
    targetItem=${itemsToReplace[$itemToReplace]}
    verbose "${itemToReplace} --- ${targetItem}" 
    if [ -d ${itemToReplace} ]; then
        backup ${itemToReplace}
    elif [ -L ${itemToReplace} ]; then
        verbose "$itemToReplace is already one symlink"
        continue
    elif [ -f ${itemToReplace} ]; then
        backup ${itemToReplace}
    fi

    verbose "Creating symlink ${itemToReplace} => ${targetItem}"
    ln -s ${targetItem} ${itemToReplace}
    if [ $? != 0 ]; then
        error "Creating symlink ${itemToReplace} => ${targetItem} has failed"
        return 1
    fi
done

exit 0
