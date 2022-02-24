#!/bin/bash
# This script is installing :
# - vundle for vim plugins

#
# installing vundle
#
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
if [ "$?" != 0 ]; then
    echo "Installing zsh has failed."
    exit 1
fi

#
# run plugin install
#
vim -c ':PluginInstall'
