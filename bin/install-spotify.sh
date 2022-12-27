#!/bin/bash
# This script is installing vscode

#
# Installing spotify
#
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/spotify.gpg

sudo apt-get update && sudo apt-get install spotify-client