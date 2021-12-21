textBold='\e[1m'
resetTextColor='\e[0m'
textColorCyan='\e[96m'
textColorRed='\e[31m'
textColorGreen='\e[32m'
textColorLightYellow='\e[93m'
textColorOrange='\e[38;5;208m'
function coloredEcho() {
    local defaultColor=$textColorCyan
    if [[ $# < 1 ]]; then
        echo '-------------------------------------------------'
        echo "$textBold\e[91mYou should pass one message at least.$resetTextColor"
        echo "\e[1mUsage : coloredEcho message.$resetTextColor"
        echo '-------------------------------------------------'
        return 1
    fi
    local textColor=$2
    if [[ $# < 2 ]]; then
        textColor=$defaultColor
    fi
    local message=$1
    echo "${textColor}${message}${resetTextColor}"
}
#coloredEcho
#coloredEcho "le chat est cyan"
#coloredEcho "le chat est jaune" '\e[93m'

function comment() {
    local message=$1
    coloredEcho "$message" $textColorGreen
}

function warning() {
    local message=$1
    coloredEcho "$message" $textColorOrange
}

function error() {
    local message=$1
    coloredEcho "$message" $textColorRed
}

function pause() {
    local message=$1
    if [ -z $1 ]; then
        message='Press any key to continue (or Ctrl+c to quit)...'
    fi
    comment $message
    read -k1 -s
}