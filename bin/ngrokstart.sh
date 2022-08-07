#!/usr/bin/zsh
# ===================================================
# this script goal is to be able to record/test a payment with stripe on local environment.
# to do so :
# - it is starting ngrok with one generic subdomain name on europe
# - it's trying to configure stripe webhook dev mode to use this new ngrok subdomain
#
# Requirements :
# you should export STRIPE_TEST with your STRIPE_API_KEY in your env (bashrc/zshrc)
# ===================================================

# loading coloring message
. $HOME/dotfiles/coloredMessage.sh

function removeDoubleQuotes() {
    local stringToClean=$1
    if [ -z $stringToClean ]; then
        echo ""
    fi

    cleanedString=$(sed -e 's/^"//' -e 's/"$//' <<<$stringToClean)
    echo $cleanedString
}

if [ -z $STRIPE_TEST_KEY ]; then
    echo "You should add something like"
    echo "export STRIPE_TEST_KEY=<YOUR STRIPE API TEST KEY HERE>"
    echo "in a non versionned/secure place"
    exit 1
fi

# =======================================================================
# Ngrok Part
# =======================================================================
# running ngrok in a screen
screen -dm ngrok http --region eu 80
waitForSeconds=2
warning "waiting $waitForSeconds secs for ngrok to be running"
sleep $waitForSeconds

# getting public url from ngrok local api
publicUrl=$(curl --silent http://127.0.0.1:4040/api/tunnels | jq '.tunnels[0].public_url')
if [ -z $publicUrl ]; then
    error "We failed to obtain public url from local ngrok api"
    exit 1
fi

# removing http|https
cleanedEndpoint=$(sed 's~http[s]*://~~g' <<<$publicUrl)
cleanedEndpoint=$(removeDoubleQuotes "$cleanedEndpoint")
echo "Actual ngrok endpoint : $cleanedEndpoint"

# =======================================================================
# Stripe Part
# =======================================================================

# removing old endpoint
oldEndpointId=$(curl --silent https://api.stripe.com/v1/webhook_endpoints -u $STRIPE_TEST_KEY: -G | jq '.data[0].id')
oldEndpointId=$(removeDoubleQuotes "$oldEndpointId")
if [ $oldEndpointId != "null" ]; then
    ### suppression du endpoint
    warning "suppression du endpoint stripe existant ($oldEndpointId)"
    curl https://api.stripe.com/v1/webhook_endpoints/$oldEndpointId -u $STRIPE_TEST_KEY: -X DELETE
fi

newEndpoint="http://$cleanedEndpoint/stripe/webhooks"
comment "setting new endpoint $newEndpoint"
### adding new one
secret=$(curl --silent https://api.stripe.com/v1/webhook_endpoints -u $STRIPE_TEST_KEY: -d url="$newEndpoint" -d "enabled_events[]"="checkout.session.completed" | jq '.secret')
secret=$(removeDoubleQuotes $secret)

echo ""
separator $textColorOrange
warning "Don't forget to set your new STRIPE_WEBHOOK_SECRET with ($secret)"
separator $textColorOrange
