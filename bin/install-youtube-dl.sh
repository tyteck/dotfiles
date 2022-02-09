#!/bin/bash
# This script is installing youtube-dl

sudo apt update -y && sudo apt install --no-install-recommends -y python ffmpeg

sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp

sudo chmod a+rx /usr/local/bin/yt-dlp

yt-dlp --version
