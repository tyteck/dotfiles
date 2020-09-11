#!/bin/bash
# This script is installing tools I'm using every day

## PHP 7.4 and all required tools
sudo add-apt-repository ppa:ondrej/php -y &&
    sudo apt update &&
    sudo apt-get install -y ansible curl wget htop fonts-firacode gnome-tweaks php7.4 screen terminator tree vim
