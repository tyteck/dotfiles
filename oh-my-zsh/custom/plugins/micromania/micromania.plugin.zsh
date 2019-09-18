alias db="docker exec -it mysqlmaster mysql -uroot -proot sfmi"
alias microbin="cd /var/www/intranet/bin"
alias micro="cd /var/www/intranet/web/webintra"
alias intratools="cd /var/www/intranet/intratools"
alias dokintra="docker exec -it intranetlocal.sfmi.lan"

alias tsox="dokexec intranetlocal.sfmi.lan phpunit --color --bootstrap sfmi/include/Sox/autoload.php sfmi/include/Sox/tests"
alias preprodlootstat="/var/www/intranet/intratools/refreshStatsLoots.sh --topreprod -v && ssh preprod \"/usr/local/sfmi/bin/generateStatsLootExcelMode.php -v\""
export GITLAB_API_TOKEN=r_wz42QJjcYKvyGVAymq
export PATH=$PATH:/var/www/intranet/intratools

function intrabin(){
    SCRIPT_TO_RUN=$1
    docker exec -it intranetlocal.sfmi.lan php ../sfmi/bin/${SCRIPT_TO_RUN}
}

