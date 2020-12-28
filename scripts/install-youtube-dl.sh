#!/bin/bash
# This script is installing youtube-dl

sudo apt update -y && sudo apt install -y python

sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl

sudo chmod a+rx /usr/local/bin/youtube-dl

youtube-dl --version
