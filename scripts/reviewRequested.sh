#!/usr/bin/zsh
# this script will retrieve PR request where I'm asked a review
# and send me a gnome notification on desktop

nbReviewRequested=$(gh api -X GET search/issues -f q='review:required user-review-requested:@me' | jq '.total_count')
if [ $nbReviewRequested -ne "0" ]; then

    notify-send foo bar
fi
