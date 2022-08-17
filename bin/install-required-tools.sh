#!/bin/bash
# This script is installing tools I'm using every day

## PHP 7.4 and all required tools
sudo add-apt-repository ppa:ondrej/php -y &&
    sudo apt update &&
    sudo apt-get install -y ansible curl wget mlocate htop jq fonts-firacode gnome-tweaks php8.1-cli php-xml php-mbstring screen terminator tree vim chrome-gnome-shell &&
    sudo apt-get remove -y apache2 libreoffice-base-core thunderbird

# installing composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '795f976fe0ebd8b75f26a6dd68f78fd3453ce79f32ecb33e7fd087d39bfeb978342fb73ac986cd4f54edd0dc902601dc') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

sudo mv composer.phar /usr/local/bin/composer
sudo apt autoremove -y
