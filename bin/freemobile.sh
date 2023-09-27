#!/usr/bin/zsh
# this script will check if there is one problem
# with Free Mobile relay antenna nearby

FREE_URL=https://mobile.free.fr/account/antennes-relais-indisponibles.csv
FILE_PATH=/tmp/antennes-relais-indisponibles.csv

# getting csv file
wget -O $FILE_PATH $FREE_URL >/dev/null 2>&1
if [ $? != 0 ];then
    MESSAGE="C'est free ou la connexion qui est down."
    notify-send "FREE-MOBILE" "$MESSAGE"
    exit 1
fi
# looking for the ones that interest me
IN_TROUBLE=$(cat antennes-relais-indisponibles.csv | grep -e "NICE" -e "TOURRETTE LEVENS" -e "ASPREMONT" | wc -l)

MESSAGE="No problemo !"
ERROR=0
if [ $IN_TROUBLE -gt 0 ]; then
    MESSAGE="L'antenne de Free est down !"
    ERROR=1
    notify-send "FREE-MOBILE" "$MESSAGE"
fi
exit $ERROR
