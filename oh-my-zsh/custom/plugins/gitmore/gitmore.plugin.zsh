# Git
# some aliases
alias gtus='git status'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'
alias gme='git merge'

# avoiding to save and git vim for default
# merge message when I'm making a git merge
export GIT_MERGE_AUTOEDIT=no

# some functions
function gitown() {
    if [ -d ".git" ]; then
        git config user.email "frederick@tyteca.net"
        git config user.name "frederick tyteca"
        success "git config done"
    fi
}

function gdelete() {
    if [ -z $1 ]; then
        comment "Usage : gdelete <BRANCH_TO_DELETE>"
        comment "This function will delete a branch locally AND remotely."
        return 1
    fi

    for BRANCH_TO_DELETE in $@; do
        comment "Branch to be deleted : $BRANCH_TO_DELETE"

        # necessary to avoid
        if [ "$BRANCH_TO_DELETE" = "master" ] || [ "$BRANCH_TO_DELETE" = "main" ] || [ "$BRANCH_TO_DELETE" = "dev" ]; then
            error "ARE YOU CRAZY ? you shouldn't delete \"$BRANCH_TO_DELETE\""
            return 1
        fi

        git show-ref --verify --quiet refs/heads/$BRANCH_TO_DELETE
        if [ $? -ne 0 ]; then
            echo "The local branch {$BRANCH_TO_DELETE} does not exists."
        else
            git branch -d $BRANCH_TO_DELETE
            if [ $? -ne 0 ]; then
                echo "Local branch {$BRANCH_TO_DELETE} deletion has failed"
            fi
        fi

        if remoteBranchExists $BRANCH_TO_DELETE; then
            git push origin --delete $BRANCH_TO_DELETE
            if [ $? -ne 0 ]; then
                echo "Branch {$BRANCH_TO_DELETE} deletion has failed"
            fi
        else
            echo "The remote branch {$BRANCH_TO_DELETE} does not exists."
        fi
    done
    return 0
}

function mergeCurrentWith() {
    if [ -z "$1" ]; then
        error "you should give the branch name you want to merge with"
        return 1
    fi
    currentBranch=$(getCurrentBranchName)
    branchNameToMergeWith=$1

    #
    # check if branch exists
    #
    if ! localBranchExists $branchNameToMergeWith; then
        error "The branch name you want to merge with does not exists"
        return 1
    fi

    comment "-- checkout $branchNameToMergeWith --"
    git checkout $branchNameToMergeWith
    if [ $? -ne 0 ]; then
        error "Checkout for the branch $branchNameToMergeWith has failed."
        return 1
    fi

    comment "-- pulling $branchNameToMergeWith --"
    git pull
    if [ $? -ne 0 ]; then
        error "Pull of branch $branchNameToMergeWith has failed."
        return 1
    fi

    comment "-- merging current $branchNameToMergeWith with $currentBranch --"
    git merge $currentBranch
    if [ $? -ne 0 ]; then
        error "Merging the branch $currentBranch with $branchNameToMergeWith has failed."
        return 1
    fi

    comment "-- pushing result --"
    git push
    if [ $? -ne 0 ]; then
        error "Pushing the branch has failed."
        return 1
    fi
    return 0
}

function cleanLocalOldBranches() {
    # get remote branches marked as gone
    goneBranches=$(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}')
    echo $goneBranches
    #git fetch -p && for branch in $goneBranches;
    #do
    #    git branch -D $branch;
    #    done
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

    CMD="git commit -m \"$commitMessage\" $commitFiles"
    #echo $CMD
    eval $CMD
    if [ $? -ne 0 ]; then
        echo "Commit has failed with command ($CMD)"
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
        error "Pushing on remote branch $currentBranchName has failed with command ($CMD)"
        return 1
    fi
}

# this function will restore one previously deleted (and committed file)
function grestore() {
    if [ -z "$1" ]; then
        warning "you should give file name you want to restore"
        return 1
    fi
    FILEPATH_TO_RESTORE=$1
    git checkout $(git rev-list -n 1 HEAD -- "$FILEPATH_TO_RESTORE") -- "$FILEPATH_TO_RESTORE"
    if [ $? -ne 0 ]; then
        error "Git restoring file $FILEPATH_TO_RESTORE has failed !"
        return 1
    fi
    return 0
}

function localBranchExists() {
    if [ -z "$1" ]; then
        error "you should give the branch name you want to check if exists"
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

function gdiffall() {
    for n in {1..20}; do
        echo ''
    done
    nbFiles=$(git ls-files -m | wc -l)
    index=1
    for fileToDiff in $(git ls-files -m); do
        echo "\n\n\n========= $fileToDiff (${index}/${nbFiles}) =========\n\n"
        git diff $fileToDiff
        let index=${index}+1
        pause
    done
}

function removeuntrackedfiles() {
    git clean -n -d
    pause "======================================================================\n\
Beware !!! All files above will be deleted !!! Ctrl+C to prevent this.\n\
======================================================================"
    git clean -f
}

function modifiedFiles() {
    backInTime=${1:-1}
    git diff HEAD~${modifiedFiles}..HEAD --compact-summary
}
