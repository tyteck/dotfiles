#!/bin/sh
# This script is installing composer locally
# even if I run i with docker it is useful locally

#
# Installing composer
#
EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    echo >&2 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

echo "Composer installed 🤗"
exit $RESULT
