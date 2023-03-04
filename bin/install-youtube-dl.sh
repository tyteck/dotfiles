#!/usr/bin/zsh
# This script is installing youtube-dl

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

sudo apt update -y && sudo apt install --no-install-recommends -y python3 ffmpeg

if [ -d /usr/local/bin/yt-dlp ]; then
    # removing "colume" mounted by docker if yt-dlp not present
    sudo rm -f /usr/local/bin/yt-dlp
fi

sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp

sudo chmod a+rx /usr/local/bin/yt-dlp

yt-dlp --version
if [ $? = 0 ]; then
    comment "yt-dlp was successfully installed"
fi
