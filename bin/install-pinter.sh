#!/usr/bin/zsh
# This script is installing pinter

if [ ! -d .vscode ]; then
    mkdir .vscode
fi

cd .vscode

ln -s ~/dotfiles/bin/pinter

settings=$(
    cat <<EOT
{
    "emeraldwalk.runonsave": {
        "commands": [
            {
                "match": "\\.php$",
                "cmd": "/home/fred/Projects/lucie/laravel/.vscode/pinter.php ${relativeFile}"
            }
        ]
    }
}
EOT
)
echo $settings
touch settings.json
#echo "$settings" >settings.json

cd ..
