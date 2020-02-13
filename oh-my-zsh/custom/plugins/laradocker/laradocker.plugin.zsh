# LaraDocker
# This plugin is useful for those who are running multiple laravel containers.
# The purpose is being able to run artisan according to the project you are in
# to use it properly you should respect some requirements.
# - using container name
# - last part of the folder (where is stored artisan) should have the same name as your container
#  		/path/../to/<containername>/artisan

function artisan() {
	# checking if artisan is there
	if [ ! -f artisan ]; then
		echo "not a laravel path"
		return 1
	fi

	# get the container name
	# container should have the same name than the last part of the path
	# tree structure
	# /path/to/containerName
	#				| artisan
	# to be able running docker exec -it --user $(id -u):$(id -g)
	containerName=$(basename $(pwd))
	if [ ! "$(docker ps -a | grep $containerName)" ]; then
		commandToRun="php artisan $@"	
	else
		# run the artisan command in the container
		commandToRun="docker exec -it $containerName php artisan $@"	
	fi
	eval $commandToRun
}

alias al="artisan list"
alias arl="artisan route:list"
alias ams="artisan migrate:status"
alias amf="artisan migrate:fresh"
alias amfs="artisan migrate:fresh --seed"
alias tinker="artisan tinker"