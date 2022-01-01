#!/usr/bin/zsh
# some dbprod shortcuts
# require dbprod to be effective on local environnement

. $HOME/dotfiles/coloredMessage.sh

function podmedias() {
    local defaultPeriod=$(date '+%Y-%m')
    local channel=$1
    local period="${2:-$defaultPeriod}"

    if [ -z $channel ]; then
        echo "You should give a channel_id (at least) as an argument to get medias"
        comment "usage : medias UCMnHkvrh_1fMWTJA_ru9ATQ 2021-12"
        return
    fi

    dbprod -e "select title, media_id, published_at,grabbed_at \
        from medias \
        where channel_id='${channel}' and published_at between '${period}-01' and now() \
        order by published_at asc"
}
