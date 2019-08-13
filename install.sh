#!/bin/bash

if [ -z $HOME ];then
    echo "Environment variable HOME not set, I prefer to stop"
    exit 1
fi

filesToReplace="$HOME/.bashrc $HOME/.bash_aliases $HOME/.vimrc $HOME/.config/Code/User/settings.json"
userChoice=""
waitForUser() {
    message=$1
    while true; do
        read -p "$message" yesOrNo
        case $yesOrNo in
        [Yy]*)
            echo "installing"
            break
            ;;
        [Nn]*)
            echo "quitting"
            exit
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

for fileToReplace in $filesToReplace; do
    file=$(basename $fileToReplace)
    sourceFile="$HOME/dotfiles/$file"
    backupFile="$fileToReplace.back"

    if [ -L $backupFile ]; then
        # if backup file already exists AND is one symlink => removing
        unlink $backupFile
    elif [ -f $backupFile ]; then
        # if backup file already exists AND is one regular file => removing
        waitForUser "Backup file $backupFile already exists. Do you agree to overwrite it ? [y/N] : "
        unlink $backupFile
    fi

    if [ -L $fileToReplace ]; then
        # if file to replace already exists AND is one symlink => removing
        unlink $fileToReplace
    elif [ -f $fileToReplace ]; then
        # if file to replace already exists AND is one regulaar file => moving
        mv $fileToReplace $backupFile
    fi 
    ln -s $sourceFile $fileToReplace
done
exit 0
