#!/bin/bash
# This script is installing vscode

#
# Installing vs code
#
wget -O /tmp/vscode_latest.deb https://go.microsoft.com/fwlink/?LinkID=760868

sudo dpkg -i /tmp/vscode_latest.deb
