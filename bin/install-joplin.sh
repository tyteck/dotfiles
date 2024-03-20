#!/bin/bash
# This script is installing joplin
# it check the installed version in $HOME/.joplin/VERSION
# download the file Joplin.AppImage in the same folder

symlinkName=Joplin.AppImage
#
# Installing joplin
#
wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash

echo "about to run AppImageLauncher, you need to click on integrate and run."
read -s -k '?Press any key to continue.'

# get current symlink target
currentAppImage=$(readlink -f $symlinkName)

# removing current version
rm -fv $currentAppImage

# removing symlink
unlink $symlinkName

# getting new version path (should have 1 only)
newAppImage=$(find $HOME/Applications -type f -name "Joplin*")

ln -s /home/fred/Applications/Joplin_dc9fc77a236a0e2e64b32a4243bc3543.AppImage Joplin.AppImage

AppImageLauncher $HOME/.joplin/Joplin.AppImage
