#!/bin/bash
# This script is installing podmytube local servers

# creating folders for podmytube local servers
baseFolder="/home/www"

for folder in playlists mp3 thumbs podcasts; do
    echo "creating $baseFolder/$folder.podmytube.com/etc"
    wwwFolder=$baseFolder/$folder.podmytube.com/www
    etcFolder=$baseFolder/$folder.podmytube.com/etc
    sudo mkdir -p $etcFolder $wwwFolder
    sudo chown -R www-data:$USER $baseFolder
    sudo chmod -R 775 $baseFolder

    echo $folder >$wwwFolder/index.html

    apacheVirtualConf=$baseFolder/$folder.podmytube.com/etc/$folder.conf
    echo "Creating apache conf file"
    cat <<EOF >$apacheVirtualConf
<VirtualHost *:80>
	ServerName $folder.dev.podmytube.com

	DocumentRoot "/home/www/$folder.podmytube.com/www"
	<Directory "/home/www/$folder.podmytube.com/www">
		Options FollowSymLinks
		AllowOverride all
		Require all granted
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/$folder.error.log
	CustomLog ${APACHE_LOG_DIR}/$folder.access.log combined
</VirtualHost>
EOF

    echo "Creating apache symlink"
    sudo ln -s $apacheVirtualConf /etc/apache2/sites-available/$folder.conf
    sudo ln -s /etc/apache2/sites-available/$folder.conf /etc/apache2/sites-enabled/$folder.conf
done
