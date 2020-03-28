# LaraDocker
# This plugin is useful for those who are running multiple laravel containers.
# The purpose is being able to run artisan according to the project you are in
# to use it properly you should respect some requirements.
# - using container name
# - last part of the folder (where is stored artisan) should have the same name as your container
#  		/path/../to/<containername>/artisan

function artisan() {
	# checking if artisan is there
	if ! fileExists "artisan" 
	then
		echo "You are not in a laravel path."
		return 1
	fi

	# get the container name
	containerName=$(getLastFolder)
	if isInstalled "docker" && containerExists $containerName
	then
		# run the artisan command in the container
		prefix="docker exec -it $containerName "
	fi
	commandToRun="${prefix}php artisan $@"
	#echo $commandToRun
	eval $commandToRun
}

function tests() {
	phpunitPath="vendor/bin/phpunit"
	# checking if artisan is there
	if ! fileExists $phpunitPath 
	then
		echo "phpunit is not available in vendor path ($phpunitPath)."
		return 1
	fi

	# get the container name
	containerName=$(getLastFolder)
	if isInstalled "docker" && containerExists $containerName
	then
		# run the artisan command in the container
		prefix="docker exec -it $containerName "
	fi
	commandToRun="${prefix}${phpunitPath} --color=always $@"
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

# check if filename exists and is executable
function fileExists() {
	fileName=$1
	if [ -x $fileName ]; then
		true
	else
		false
	fi
}

# check if one program is installed on this computer
function isInstalled(){
	programName=$1
	if [ -x "$(command -v $programName)" ]; then
		true
	else
		false
	fi
}

alias aig="artisan ide-helper:generate"
alias aie="artisan ide-helper:eloquent"
alias al="artisan list"
alias arl="artisan route:list"
alias am="artisan migrate"
alias amf="artisan migrate:fresh"
alias amfs="artisan migrate:fresh --seed"
alias amr="artisan migrate:rollback"
alias ams="artisan migrate:status"
alias tinker="artisan tinker"
