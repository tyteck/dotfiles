#!/bin/sh

echo "============================="
echo "------------ WIP ------------"
echo "============================="

sudo apt update
sudo apt install git curl gnupg apache2 cifs-utils -y

echo "Type your password for freebox user."
echo "It will be asked when changing shell."
sudo passwd freebox

git clone https://github.com/tyteck/dotfiles.git
./dotfiles/scripts/install-oh-my-zsh.sh

echo "downloading the package and installing it ..."
wget https://downloads.plex.tv/plex-media-server-new/1.23.1.4602-280ab6053/debian/plexmediaserver_1.23.1.4602-280ab6053_arm64.deb && sudo apt install ./plexmediaserver*.deb

echo "adding plex repo to apt ..."
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -

echo "installing podmytube local servers ..."
./dotfiles/scripts/install-podmytube-local-servers.sh

exit 0
