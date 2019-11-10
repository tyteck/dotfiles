# LaraDocker


function artisan() {
	# checking if artisan is there
	if [ ! -f artisan ];then
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
		return 1
	fi

	# run the artisan command in the container
	commandToRun="docker exec -it $containerName php artisan $@"
	eval $commandToRun
}
