#!/bin/bash
# This script is installing system monitor, freon and gravatar

sudo apt install -y gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 lm-sensors hddtemp

sudo sensors-detect

echo '======================================================='
echo 'install gnome system monitor and freon'
echo 'click https://extensions.gnome.org/extension/120/system-monitor/'
echo 'click https://extensions.gnome.org/extension/841/freon/'
echo 'click https://extensions.gnome.org/extension/1262/bing-wallpaper-changer/'
echo 'click https://extensions.gnome.org/extension/21/workspace-indicator/'
echo 'click https://extensions.gnome.org/extension/16/auto-move-windows/'
echo 'click https://extensions.gnome.org/extension/1015/gravatar/'

echo 'For gravatar you have to go in gnome tweaks > extensions > gravatar > setting > set your email'
echo '======================================================='
