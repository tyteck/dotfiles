# Git
# some aliases
alias gtus='git status'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'
alias gme='git merge'

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

    if remoteBranchExists $BRANCH_TO_DELETE; then
        git push origin --delete $BRANCH_TO_DELETE
        if [ $? -ne 0 ]; then
            echo "Branch {$BRANCH_TO_DELETE} deletion has failed"
            return 1
        fi
    else
        echo "The remote branch {$BRANCH_TO_DELETE} does not exists."
    fi
}

function mergeCurrentWith() {
    if [ -z "$1" ]; then
        echo "you should give the branch name you want to merge with"
        return 1
    fi
    currentBranch=$(getCurrentBranchName)
    branchNameToMergeWith=$1

    #
    # check if branch exists
    #
    if ! localBranchExists $branchNameToMergeWith; then
        echo "The branch name you want to merge with does not exists"
        return 1
    fi

    git checkout $branchNameToMergeWith
    if [ $? -ne 0 ]; then
        echo "Checkout for the branch $branchNameToMergeWith has failed."
        return 1
    fi

    git pull
    if [ $? -ne 0 ]; then
        echo "Pull of branch $branchNameToMergeWith has failed."
        return 1
    fi

    git merge $currentBranch
    if [ $? -ne 0 ]; then
        echo "Merging the branch $currentBranch with $branchNameToMergeWith has failed."
        return 1
    fi

    git push
    if [ $? -ne 0 ]; then
        echo "Pushing the branch has failed."
        return 1
    fi
    return 0
}

# Git commit then push in one command
# if no file is specified the . folder is commit then pushed
function gmit() {
    # files to commit
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
                exit 1
            fi
            if [ -z $commitFiles ]; then
                commitFiles="$1"
            else
                commitFiles="$commitFiles $1"
            fi
            ;;
        esac
        shift
    done

    if [ -z ${commitFiles} ]; then
        commitFiles='.'
    fi

    git commit -m "$commitMessage" $commitFiles
    if [ $? -ne 0 ]; then
        echo "Commit has failed"
        return 1
    fi

    currentBranchName=$(getCurrentBranchName)
    if ! remoteBranchExists $currentBranchName; then
        CMD="git push --set-upstream origin $currentBranchName"
    else
        CMD="git push"
    fi
    eval $CMD
    if [ $? -ne 0 ]; then
        echo "Pushing on remote branch $currentBranchName has failed"
        return 1
    fi
}

# this function will restore one previously deleted (and committed file)
function grestore() {
    if [ -z "$1" ]; then
        echo "you should give file name you want to restore"
        return 1
    fi
    FILEPATH_TO_RESTORE=$1
    git checkout $(git rev-list -n 1 HEAD -- "$FILEPATH_TO_RESTORE") -- "$FILEPATH_TO_RESTORE"
    if [ "$?" != 0 ]; then
        echo "Git restoring file $FILEPATH_TO_RESTORE has failed !"
        return 1
    fi
    return 0
}

function localBranchExists() {
    if [ -z "$1" ]; then
        echo "you should give the branch name you want to check if exists"
        return 1
    fi
    localBranchName=$1
    git show-ref --verify --quiet refs/heads/$localBranchName
    if [ $? -eq 0 ]; then
        true
    else
        false
    fi
}

function remoteBranchExists() {
    if [ -z "$1" ]; then
        echo "you should give the remote branch name you want to check if exists"
        return 1
    fi
    remoteBranchName=$1
    git show-ref --verify --quiet refs/remotes/origin/$remoteBranchName
    if [ $? -eq 0 ]; then
        true
    else
        false
    fi
}

function getCurrentBranchName() {
    echo $(git rev-parse --abbrev-ref HEAD)
}
