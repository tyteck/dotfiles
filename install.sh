#!/bin/bash

filesToReplace=".bashrc .bash_aliases .vimrc"
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

for file in $filesToReplace; do
    fileInHome="$HOME/$file"
    fileFromRepo="$HOME/dotfiles/$file"
    backupFile="$fileInHome.back"

    if [ -L $backupFile ]; then
        # if backup file already exists AND is one symlink => removing
        unlink $backupFile
    elif [ -f $backupFile ]; then
        # if backup file already exists AND is one regular file => removing
        waitForUser "Backup file $backupFile already exists. Do you agree to overwrite it ? [y/N] : "
        unlink $backupFile
    fi

    if [ -L $fileInHome ]; then
        # if file to replace already exists AND is one symlink => removing
        unlink $fileInHome
    elif [ -f $fileInHome ]; then
        # if file to replace already exists AND is one regulaar file => moving
        mv $fileInHome $backupFile
    fi 
    ln -s $fileFromRepo $fileInHome
done
exit 0
