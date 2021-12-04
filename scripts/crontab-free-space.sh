#!/usr/bin/zsh
# This script will frr some space on disk
# It should be crontabbed in root crontab

function removeOldSnaps() {
    set -eu
    LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
        while read snapname revision; do
            snap remove "$snapname" --revision="$revision" >/dev/null 2>&1
        done
}

# cleaning journal
journalctl --vacuum-time=1d --quiet

# cleaning apt archives
apt-get clean

# cleaning old docker images
docker system prune -f >/dev/null 2>&1

# removing old snaps
removeOldSnaps

# cleaning unused docker volumes
# chis will not delete any container or any volume in use!
docker volume rm $(docker volume ls -qf dangling=true) >/dev/null 2>&1
