#!/bin/bin/zsh
# This script is installing some of the containers I'am always using


# docker folder
docker network create nginx-proxy && \
sudo mkdir /var/opt/docker && \
sudo chown -R $USER:docker /var/opt/docker/ \


# nginx-proxy
cd /var/opt/docker/ && git clone git@github.com:tyteck/nginx-proxy.git && cd /var/opt/docker/nginx-proxy && ./start.sh && docker compose up -d

# mailhog
cd /var/opt/docker/ && git clone git@github.com:tyteck/mailhog-compose.git mailhog && cd mailhog && docker compose up -d

# mysqlserver
cd /var/opt/docker/ && git clone git@github.com:tyteck/docker-mysqlServer.git mysqlserver && cd mysqlserver 

# phpmyadmin
cd /var/opt/docker/ && git clone git@github.com:tyteck/phpmyadmin.git && cd phpmyadmin 

echo "get the .env files for mysqlserver and phpmyadmin before upping them"