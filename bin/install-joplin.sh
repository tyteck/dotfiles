#!/bin/bash
# This script is installing joplin

#
# Installing joplin
#
wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash

echo "you should have a $HOME/.joplin folder"
echo "run the ~/$HOME/.joplin/Joplin.AppImage and choose integrate & run (AppImageLauncher)"
echo "then you have to recreate the Joplin.AppImage symlink in $HOME/Applications"

exit 0
