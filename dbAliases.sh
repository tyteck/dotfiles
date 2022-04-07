#!/usr/bin/zsh
# some dbprod shortcuts
# require dbprod to be effective on local environnement

. $HOME/dotfiles/coloredMessage.sh

function podmedias() {
    local defaultPeriod=$(date '+%Y-%m')
    local channel=$1
    local period="${2:-$defaultPeriod}"

    if [ -z $channel ]; then
        echo 'You should give a channel_id (at least) as an argument to get medias'
        comment "usage : $funcstack[1] UCMnHkvrh_1fMWTJA_ru9ATQ 2021-12"
        return
    fi

    where="where channel_id='${channel}' and published_at between '${period}-01' and now() \
        order by published_at asc"

    dbprod -e "select title, media_id, published_at,grabbed_at from medias $where;\
        select count(*) as nb_medias_published from medias $where;"
}

function podchannelinfos() {
    local channel=$1

    if [ -z $channel ]; then
        echo 'You should give a channel_id (at least) as an argument to get infos on channel'
        comment "usage : $funcstack[1] UCMnHkvrh_1fMWTJA_ru9ATQ"
        return
    fi
    # this works because active is unsigned int
    dbprod -e "select channels.*, \
        users.firstname, \
        users.lastname, \
        users.email, \
        categories.name as category, \
        languages.iso_name as language \
        from channels \
        inner join users using(user_id) \
        inner join categories on channels.category_id=categories.id \
        inner join languages on channels.language_id=languages.id \
        where channel_id='${channel}' \G"
}

function podtogglechannel() {
    local channel=$1

    if [ -z $channel ]; then
        echo 'You should give a channel_id (at least) as an argument to be able to toggle active state of channel'
        comment "usage : $funcstack[1] UCMnHkvrh_1fMWTJA_ru9ATQ"
        return
    fi
    # this works because active is unsigned int
    dbprod -e "update channels set active=1-active where channel_id='${channel}'"
}
