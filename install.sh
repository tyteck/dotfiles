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

function createBackupFile() {
    local fileToBeBackuped=$1
    local backupFile=$2
    verbose "backuping file ${fileToBeBackuped} => ${backupFile}"
    mv $fileToBeBackuped $backupFile
    if [ $? != 0 ]; then
        errorAndExit "Creating backup file ${backupFile} from ${fileToBeBackuped} has failed"
    fi
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
        errorAndExit "Removing ${fileToRemove} has failed"
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

#
# Files I will replace with symlinks to their dotfiles equivalent.
#
filesToReplaceWithSymlink="$HOME/.bashrc \
    $HOME/.bash_aliases \
    $HOME/.vimrc \
    $HOME/.config/Code/User/settings.json\
    $HOME/.config/Code/User/keybindings.json\
    "

if [ -z $HOME ]; then
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
for fileToReplaceWithSymlink in $filesToReplaceWithSymlink; do
    fileNameToBeReplaced=$(basename $fileToReplaceWithSymlink)
    directoryWhereIsLocatedTheFileToReplace=$(dirname $fileToReplaceWithSymlink)

    sourceFile="$HOME/dotfiles/${fileNameToBeReplaced}"
    backupFile="$fileToReplaceWithSymlink.back"

    #echo "--$fileToReplaceWithSymlink--"
    #continue
    #
    # Creating target directory
    #
    if [ ! -d $directoryWhereIsLocatedTheFileToReplace ]; then
        verbose "Creating directory ${directoryWhereIsLocatedTheFileToReplace}"
        mkdir -p $directoryWhereIsLocatedTheFileToReplace
    fi

    if [ -L $backupFile ]; then
        #
        # if backup file already exists AND is one symlink => removing
        #
        verbose "backup file ${backupFile} is a symlink => removing"
        removeExistingFile ${backupFile}
    elif [ -f $backupFile ]; then
        #
        # if backup file already exists AND is one regular file => removing
        # else => exit
        #
        verbose "backup file ${backupFile} is a regular file => asking what to do"
        waitForUser "Backup file $backupFile already exists. Do you agree to overwrite it ? [y/N] : "
        removeExistingFile ${backupFile}
    fi

    if [ -L $fileToReplaceWithSymlink ]; then
        #
        # if file to replace already exists AND is one symlink => removing
        #
        removeExistingFile ${fileToReplaceWithSymlink}
    elif [ -f ${fileToReplaceWithSymlink} ]; then
        #
        # if file to replace already exists AND is one regulaar file => moving
        #
        createBackupFile "${fileToReplaceWithSymlink}" "${backupFile}"
    fi

    verbose "Creating symlink ${fileToReplaceWithSymlink} => ${sourceFile}"
    ln -s ${sourceFile} ${fileToReplaceWithSymlink}
    if [ $? != 0 ]; then
        errorAndExit "Creating symlink ${fileToReplaceWithSymlink} => ${sourceFile} has failed"
    fi
done
exit 0
