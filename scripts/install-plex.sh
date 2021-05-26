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

echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
#wget https://downloads.plex.tv/plex-media-server-new/1.18.0.1913-e5cc93306/debian/plexmediaserver_1.18.0.1913-e5cc93306_arm64.deb && sudo apt install ./plex*.deb

exit 0
