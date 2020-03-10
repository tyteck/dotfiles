# LaraDocker
# This plugin is useful for those who are running multiple laravel containers.
# The purpose is being able to run artisan according to the project you are in
# to use it properly you should respect some requirements.
# - using container name
# - last part of the folder (where is stored artisan) should have the same name as your container
#  		/path/../to/<containername>/artisan
false=1
true=0

function artisan() {
	# checking if artisan is there
	if [ ! -f artisan ]; then
		echo "not a laravel path"
		return 1
	fi

	dockerIsInstalled=$false
	if [ -x "$(command -v docker)" ]; then
		dockerIsInstalled=$true
	fi

	# get the container name
	# container should have the same name than the last part of the path
	# tree structure
	# /path/to/containerName
	#				| artisan
	# to be able running docker exec -it --user $(id -u):$(id -g)
	containerName=$(getLastFolder)
	if [[ $dockerIsInstalled -eq $true && "$(docker ps -a | grep $containerName)" ]];then
		# run the artisan command in the container
		commandToRun="docker exec -it $containerName php artisan $@"
	else
		# run the artisan command line
		commandToRun="php artisan $@"
	fi
	#echo $commandToRun
	eval $commandToRun
}

function getLastFolder() {
	echo $(basename $(pwd))
}

function isContainerName() {
	containerName=$1
	if [ "$(docker ps -a | grep $containerName)" ]; then
		return 0
	fi
	return 1
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
