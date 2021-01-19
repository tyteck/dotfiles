# LaraDocker
# This plugin is useful for those who are running multiple laravel containers.
# The purpose is being able to run artisan according to the project you are in
# to use it properly you should respect some requirements.
# - using container name
# - last part of the folder (where is stored artisan) should have the same name as your container
#  		/path/../to/<containername>/artisan

function isLaravelPath() {
	if fileExists "artisan"; then
		true
	else
		false
	fi
}

function laravelFirstRun() {
	if ! isLaravelPath; then
		echo "You are not in a laravel path."
		return 1
	fi

	mkdir -p storage/framework/cache
	mkdir -p storage/framework/sessions
	mkdir -p storage/framework/testing
	mkdir -p storage/framework/views
}

function artisan() {

	if ! fileExists "artisan"; then
		echo "You are not in a laravel path."
		return 1
	fi

	# get the container name
	containerName=$(getLastFolder)
	dockerPrefix=''
	if isInstalled "docker" && containerExists $containerName; then
		# run the artisan command in the container
		dockerPrefix="docker exec -it --user www-data $containerName "
	fi
	commandToRun="${dockerPrefix} php artisan $@"
	#echo $commandToRun
	eval $commandToRun
}

function tests() {
	executablePath="vendor/bin/phpunit"
	# checking if executable is there
	if ! fileExists $executablePath; then
		echo "phpunit is not available in path ($executablePath)."
		return 1
	fi

	# get the container name
	containerName=$(getLastFolder)
	prefix=''
	if isInstalled "docker" && containerExists $containerName; then
		# run the artisan command in the container
		prefix="docker exec -it --user www-data $containerName "
	fi
	commandToRun="${prefix}${executablePath} $@"
	#echo $commandToRun
	eval $commandToRun
}

# grab the last part of path
# /path/to/folder => folder
function getLastFolder() {
	echo $(basename $(pwd))
}

# check if containerName is up and running
function containerExists() {
	containerName=$1
	if [ "$(docker ps -a | grep $containerName)" ]; then
		true
	else
		false
	fi
}

# check if filename exists
function fileExists() {
	fileName=$1
	if [ -f $fileName ]; then
		true
	else
		false
	fi
}

# check if filename is executable
function isFileExecutable() {
	fileName=$1
	if [ -x $fileName ]; then
		true
	else
		false
	fi
}

# check if one program is installed on this computer
function isInstalled() {
	programName=$1
	if [ -x "$(command -v $programName)" ]; then
		true
	else
		false
	fi
}

alias acc="artisan cache:clear"
alias ads="artisan db:seed"
alias aig="artisan ide-helper:generate"
alias aie="artisan ide-helper:eloquent"
alias al="artisan list"
alias arl="artisan route:list"
alias am="artisan migrate"
alias amf="artisan migrate:fresh"
alias amfs="artisan migrate:fresh --seed"
alias amr="artisan migrate:rollback"
alias ams="artisan migrate:status"
alias aoc="artisan optimize:clear"
alias aqf="artisan queue:flush"
alias aqr="artisan queue:restart"
alias arall="artisan queue:restart && artisan optimize:clear"
alias tinker="artisan tinker"

alias composer='docker run --rm -v $(pwd):/app composer:latest '
alias cdu='composer dump-autoload'
alias composer1='/usr/local/bin/composer'
alias "composer install"="composer --ignore-platform-reqs"
