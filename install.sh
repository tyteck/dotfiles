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

for file in $filesToReplace;do
    fileInHome="$HOME/$file"
    fileFromRepo="$HOME/dotfiles/$file"
    backupFile="$fileInHome.back"
    if [ -f $backupFile ]; then
        waitForUser "Backup file $backupFile already exists. Do you agree to overwrite it ? [y/N] : "
        unlink $backupFile
    fi
    mv $fileInHome $backupFile
    ln -s $fileFromRepo $fileInHome
done
exit 0
