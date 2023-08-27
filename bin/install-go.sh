#!/usr/bin/zsh
# This script is installing go

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

version="1.21.0"
filename="go${version}.linux-amd64.tar.gz"
downloaded="${HOME}/Downloads/${filename}"

comment "Downloading version : $version ..."
wget -O $downloaded https://dl.google.com/go/$filename

#removing previous version & installing downloaded
comment "Installing ..."
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $downloaded

comment "Cleaning ..."
rm -fv $downloaded

go version
if [ $? = 0 ]; then
    comment "Install done"
fi
