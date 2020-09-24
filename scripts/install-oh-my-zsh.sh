#!/bin/bash
# This script is installing :
# - zsh (and make it default shell)
# - oh my zsh

#
# installing zsh
#
sudo apt install zsh
if [ "$?" != 0 ]; then
    echo "Installing zsh has failed."
    exit 1
fi

#
# Make it default shell
#
echo "======================================================="
echo "Changing your shell requires you to type your password."
echo "======================================================="
chsh -s $(which zsh)
if [ "$?" != 0 ]; then
    echo "Setting zsh as default shell has failed."
    exit 1
fi

#
# Installing oh my zsh
#
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
if [ "$?" != 0 ]; then
    echo "Getting Oh-my-zsh has failed."
    exit 1
fi
