# get the ip address for one container
dokip() {
	CONTAINER_NAME=$1
	docker inspect $CONTAINER_NAME --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

dokips() {
	for CONTAINER_NAME in $(docker ps --format '{{.Names}}'); do
		echo $CONTAINER_NAME --- $(dokip $CONTAINER_NAME)
	done
}

dokrmi() {
	IMAGE_NAME=$1
	docker rmi $(docker image ls --filter "reference=$IMAGE_NAME" -q)
}

