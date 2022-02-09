#!/usr/bin/zsh
# this script will retrieve PR request where I'm asked a review
# and send me a gnome notification on desktop

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

if [ -z $GITHUB_LOGIN ] || [ -z $GITHUB_TOKEN ]; then
    error "You should add something like"
    error "export GITHUB_LOGIN=<YOUR GITHUB LOGIN>"
    error "export GITHUB_TOKEN=<YOUR GITHUB PERSONAL TOKEN>"
    error "in a non versionned/secure place"
    exit 1
fi

repositories=(actualtysoft/laravel) # actualtysoft/nina)
for repository in $repositories; do
    comment "Processing $repository"
    curl --silent -u $GITHUB_LOGIN:$GITHUB_TOKEN https://api.github.com/repos/actualtysoft/laravel/pulls | jq # "[.[] | {url: .url, from: .user.login, requested: [.requested_reviewers[].login==ftytecaActual] }]")

done
exit 0

#notify-send foo bar
