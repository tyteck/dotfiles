# Git
# some aliases
alias gtus='git status'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gbr='git branch'
alias gco='git checkout'
alias gme='git merge'
alias glastlogs='git log -n 3'
alias dlaudio='yt-dlp --audio-format mp3 --extract-audio'

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

    local protectedBranches="main master dev develop"

    for BRANCH_TO_DELETE in $@; do
        comment "Branch to be deleted : $BRANCH_TO_DELETE"

        # necessary to avoid
        if in_array $BRANCH_TO_DELETE $protectedBranches; then
            error "ARE YOU CRAZY ? you shouldn't delete \"$BRANCH_TO_DELETE\""
            return 1
        fi

        git show-ref --verify --quiet refs/heads/$BRANCH_TO_DELETE
        if [ $? -ne 0 ]; then
            warning "The local branch {$BRANCH_TO_DELETE} does not exists."
        else
            git branch -d $BRANCH_TO_DELETE
            if [ $? -ne 0 ]; then
                error "Local branch {$BRANCH_TO_DELETE} deletion has failed"
            fi
        fi

        if remoteBranchExists $BRANCH_TO_DELETE; then
            git push origin --delete $BRANCH_TO_DELETE
            if [ $? -ne 0 ]; then
                error "Branch {$BRANCH_TO_DELETE} deletion has failed"
            fi
        else
            warning "The remote branch {$BRANCH_TO_DELETE} does not exists."
        fi
    done
    return 0
}

function mergeToMain() {
    local currentBranch=$(getCurrentBranchName)
    # merge to dev
    mergeCurrentWith dev

    # merge to main
    mergeCurrentWith main

    # delete feat. branch
    gdelete $currentBranch
}

function mergeCurrentWith() {
    if [ -z "$1" ]; then
        error "you should give the branch name you want to merge with"
        return 1
    fi
    local currentBranch=$(getCurrentBranchName)
    local branchNameToMergeWith=$1

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

    comment "-- merging $branchNameToMergeWith <= $currentBranch --"
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
    local commitFiles=""
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

    local cmd="git commit -m \"$commitMessage\" $commitFiles"
    eval $cmd
    if [ $? -ne 0 ]; then
        echo "Commit has failed with command ($cmd)"
        return 1
    fi

    currentBranchName=$(getCurrentBranchName)
    if ! remoteBranchExists $currentBranchName; then
        cmd="git push --set-upstream origin $currentBranchName"
    else
        cmd="git push"
    fi
    eval $cmd
    if [ $? -ne 0 ]; then
        error "Pushing on remote branch $currentBranchName has failed with command ($cmd)"
        return 1
    fi
}

# this function will restore one previously deleted (and committed file)
function grestore() {
    if [ -z "$1" ]; then
        warning "you should give file name you want to restore"
        return 1
    fi
    local FILEPATH_TO_RESTORE=$1
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
    local localBranchName=$1
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
    local remoteBranchName=$1
    git show-ref --verify --quiet refs/remotes/origin/$remoteBranchName
    if [ $? -eq 0 ]; then
        true
    else
        false
    fi
}

function renamebranch() {
    local newBranchName=$1
    if [ -z $newBranchName ]; then
        error "You should give a new name to the current branch."
        return 1
    fi

    local oldBranchName=$(getCurrentBranchName)
    if [ -z $oldBranchName ]; then
        error "you are not in a repository."
        return 1
    fi

    # update local branch from remote origin
    if remoteBranchExists $oldBranchName; then
        git checkout $currentBranch
    fi

    # renaming local
    git branch -m $newBranchName
    if [ $? -ne 0 ]; then
        error "Renaming ${oldBranchName} to ${newBranchName} has failed"
        return false
    fi

    if remoteBranchExists $oldBranchName; then
        # pushing new one on remote
        git push origin -u ${newBranchName}
        if [ $? -ne 0 ]; then
            error "Pushing ${newBranchName} has failed"
            return false
        fi

        # delete old one
        deleteRemoteBranch ${oldBranchName}
    fi
    comment "Branch ${oldBranchName} has been renamed to ${newBranchName}"
}

function deleteRemoteBranch() {
    local remoteBranchName=$1
    if [ -z $remoteBranchName ]; then
        error "You should give a new name to the current branch."
        return false
    fi

    if ! remoteBranchExists $remoteBranchName; then
        warning "The remote branch {$remoteBranchName} does not exists."
        return true
    fi

    git push origin --delete $remoteBranchName
    if [ $? -ne 0 ]; then
        error "Branch {$remoteBranchName} deletion has failed"
        return false
    fi
    comment "Branch ${remoteBranchName} has been successfully deleted"
    return true
}

function getCurrentBranchName() {
    echo $(git rev-parse --abbrev-ref HEAD)
}

function gdiffall() {
    for n in {1..20}; do
        echo ''
    done
    local nbFiles=$(git ls-files -m | wc -l)
    local index=1
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
    local backInTime=${1:-1}
    comment "Here are the file you modified"
    git diff HEAD~${backInTime}..HEAD --compact-summary
}

function commiturl() {
    local hash=$1
    if [ -z $hash ]; then
        error "You need to give the commit hash ot get url."
        return 1
    fi
    local remote=$(git remote -v | awk '/(fetch)/ {print $2}' | sed 's/:/\// ; s/git@/https:\/\// ; s/perso\.github\.com/github\.com/; s/\.git// ')
    echo "$remote/commit/$hash"
}

function prs() {
    gh pr list --author ftytecaActual
}

function prw() {
    gh pr list --author ftytecaActual --web
}

function cleanMyOldClosedPrs() {
    gh pr list --state closed --author ftytecaActual --json headRefName --jq '.[].headRefName' | xargs -n 1 git branch -D
}
