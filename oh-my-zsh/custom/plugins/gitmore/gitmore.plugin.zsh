# Git
# some aliases
alias gtus='git status'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'

# some functions
function gitown() {
	if [ -d ".git" ]; then
		git config user.email "frederick@tyteca.net"
		git config user.name "frederick tyteca"
		success "git config done"
	fi
}

function gdelete() {
	BRANCH_TO_DELETE=$1
	if [ -z $BRANCH_TO_DELETE ]; then
		echo "To delete a branch we need a branch name ... don't you think so ?"
		return 1
	fi

	# necessary to avoid
	if [ "$BRANCH_TO_DELETE" = "master" ]; then
		echo "ARE YOU CRAZY ??????"
		return 0
	fi

	git show-ref --verify --quiet refs/heads/$BRANCH_TO_DELETE
	if [ $? -ne 0 ]; then
		echo "The local branch {$BRANCH_TO_DELETE} does not exists."
	else
		git branch -d $BRANCH_TO_DELETE
		if [ $? -ne 0 ]; then
			echo "Local branch {$BRANCH_TO_DELETE} deletion has failed"
			return 1
		fi
	fi

	git show-ref --verify --quiet refs/remotes/origin/$BRANCH_TO_DELETE
	if [ $? -eq 0 ]; then
		git push origin --delete $BRANCH_TO_DELETE
		if [ $? -ne 0 ]; then
			echo "Branch {$BRANCH_TO_DELETE} deletion has failed"
			return 1
		fi
	else
		echo "The remote branch {$BRANCH_TO_DELETE} does not exists."
	fi
}

# Git commit then push in one command
# if no file is specified the . folder is commit then pushed
function gmit() {
	commitFiles=""
	while [ $# -gt 0 ]; do
		case $1 in
		'-?' | '-h' | '--help')
			usage
			;;
		'-m')
			commitMessage=$2
			shift
			;;
		*)
			if [ ! -f $1 ] && [ ! -d $1 ]; then
				echo "file/folder $1 doesn't exists"
			else
				commitFiles="$commitFiles $1"
			fi
			;;
		esac
		shift
	done
	if [[ -z ${commitFiles} ]]; then
		commitFiles='.'
	fi
	CMD="git commit -m \"$commitMessage\" $commitFiles && git push"
	eval $CMD
	if [ "$?" != 0 ]; then
		echo "Commit has failed"
		return 1
	fi
}

# this function will restore one previously deleted (and committed file)
function grestore() {
	FILEPATH_TO_RESTORE=$1
	git checkout $(git rev-list -n 1 HEAD -- "$FILEPATH_TO_RESTORE") -- "$FILEPATH_TO_RESTORE"
	if [ "$?" != 0 ]; then
		echo "Git restoring file $FILEPATH_TO_RESTORE has failed !"
		return 1
	fi
	return 0
}
