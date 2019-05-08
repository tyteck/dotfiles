# Config files and shortcut for my usage of linux

## Introduction
I'm working on linux (ubuntu 18.04) from multiple places (work, vps, home) and 
this is the best way (til now) I found to use same aliases/conf on every 
server/machine 

## Installation 

```
git clone git@github.com:tyteck/dotfiles.git

if [ -f ~/.bash_aliases ];then mv ~/.bash_aliases ~/.bash_aliases.back;fi

ln -s dotfiles/.bash_aliases ~/.bash_aliases

ln -s dotfiles/.vimrc ~/.vimrc
```


Some alias require credentials and they are stored in dotfiles/.creds
```
cat dotfiles/.creds-sample > dotfiles/.creds
```
I will be glad to get any tips to improve this :)


## VSCode settings
rm -fv ~/.config/Code/User/settings.json && ln -s ~/dotfiles/vscode_setting.json ~/.config/Code/User/settings.json


## docker ps/images settings
ln -s ~/dotfiles/docker_config.json ~/.docker/config.json

