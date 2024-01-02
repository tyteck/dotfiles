#!/usr/bin/zsh
# This script is updating some of the containers I'am always using

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

for image in "mailhog/mailhog" "mysql:5.7" "phpmyadmin/phpmyadmin:latest" "jwilder/nginx-proxy:alpine" \
    "jrcs/letsencrypt-nginx-proxy-companion" "composer:2.0" "node:19.0-buster" "php:8.2-apache-buster"; do
    comment "updating $image"
    docker pull $image
done
