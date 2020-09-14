#!/bin/bash
# This script is installing system monitor

sudo apt install -y gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 lm-sensors hddtemp

sudo sensors-detect

echo "======================================================="
echo "install gnome system monitor and freon"
echo "click https://extensions.gnome.org/extension/120/system-monitor/"
echo "click https://extensions.gnome.org/extension/1180/freon/"
echo "======================================================="
