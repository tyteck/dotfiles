#!/bin/bash
# ~/bin/slack-guard.sh

hour=$(date +%H)
minute=$(date +%M)
day=$(date +%u)  # 1=lundi, 7=dimanche

# Week-end (samedi=6, dimanche=7)
if [ "$day" -ge 6 ]; then
    killall slack 2>/dev/null
    exit 0
fi

# Convertir en minutes depuis minuit
now=$((10#$hour * 60 + 10#$minute))
start=$((8 * 60 + 30))   # 8h30
end=$((18 * 60 ))    # 18h00

# Hors heures de bureau
if [ "$now" -lt "$start" ] || [ "$now" -ge "$end" ]; then
    killall slack 2>/dev/null
fi
