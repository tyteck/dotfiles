# Config files and shortcut for my usage of linux

## Introduction
I'm working on linux (ubuntu 18.04) from multiple places (work, vps, home) and 
this is the best way (til now) I found to use same aliases/conf on every 
server/machine 

## Installation 
```
./dotfiles/install.sh
```
Should install .bashrc, .bash_aliases and .vimrc (at the moment)

## VSCode settings
VSCode is a great ide, but sharing same conf from all places is much greater :).

```
if [ -f .config/Code/User/settings.json ];then mv .config/Code/User/settings.json .config/Code/User/settings.json.back;fi
ln -s ~/dotfiles/vscode_setting.json ~/.config/Code/User/settings.json

if [ -f .config/Code/User/keybindings.json ];then mv .config/Code/User/keybindings.json .config/Code/User/keybindings.json.back;fi
ln -s ~/dotfiles/vscode_keybindings.json .config/Code/User/keybindings.json

if [ -d .config/Code/User/snippets ];then mv .config/Code/User/snippets .config/Code/User/snippets.back;fi
rm -rfv ~/.config/Code/User/snippets && ln -s ~/dotfiles/vscode_snippets ~/.config/Code/User/snippets
```


## docker ps/images settings
```
ln -s ~/dotfiles/docker_config.json ~/.docker/config.json
```

