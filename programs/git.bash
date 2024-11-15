alias git_count_commits='git rev-list --all --count'
alias git_count_commits_by_user='git shortlog -s -n'
alias git_diff_files_last_commit='git diff --stat HEAD^1'
alias git_diff_last_commit='git diff HEAD^1'

function git_overleaf_boostrap() {
    git_gitignore_create latex >.gitignore
    echo _main.pdf >>.gitignore
}

function git_overleaf_push_commit_all() {
    git commit -am "Update from local git"
    git push
}

function git_assume_unchanged() {
    : ${1?"Usage: ${FUNCNAME[0]} <file>"}
    git update-index --assume-unchanged $1
}

function git_assume_unchanged_disable() {
    : ${1?"Usage: ${FUNCNAME[0]} <file>"}
    git update-index --no-assume-unchanged $1
}

function git_branch_remove_local_and_remote() {
    : ${1?"Usage: ${FUNCNAME[0]} <branch-name>"}
    git branch -d $1
    git push origin --delete $1
}

function git_branch_all_remotes_checkout_and_reset() {
    local CURRENT=$(git branch --show-current)
    git fetch -p origin
    git branch -r | grep -v '\->' | while read -r remote; do
        git reset --hard
        git clean -ndf
        log_msg "updating ${remote#origin/}"
        git checkout "${remote#origin/}"
        if test $? != 0; then
            log_error "cannot goes to ${remote#origin/} because there are local changes" && return 1
        fi
        git pull --all
        if test $? != 0; then
            log_error "cannot pull ${remote#origin/} because there are local changes" && return 1
        fi
    done
    log_msg "returning to branch $CURRENT"
    git checkout $CURRENT
}

function git_push_after_amend_all() {
    git commit -a --amend --no-edit
    git push --force
}

function git_gitignore_create() {
    : ${1?"Usage: ${FUNCNAME[0]} <contexts,..>"}
    curl -L -s "https://www.gitignore.io/api/$1"
}

function git_formated_patch_n_last_commits() {
    : ${1?"Usage: ${FUNCNAME[0]} <number_of_last_commits>"}
    git format-patch HEAD~$1
}

function git_formated_patch_apply() {
    git am <"$@"
}

function git_subdirs_pull() {
    find . -type d -iname .git | sed 's/\.git//g' | while read i; do
        (
            cd "$i"
            if test -d .git; then
                log_msg "pull on $i"
                git pull
            fi
        )
    done
}

function git_subdirs_reset_clean() {
    find . -type d -iname .git | sed 's/\.git//g' | while read i; do
        (
            cd "$i"
            if test -d .git; then
                log_msg "pull on $i"
                git reset --hard
                git clean -df
                git pull
            fi
        )
    done
}

function git_tag_move_to_head_and_push() {
    git tag -d $1
    git tag $1
    git push --force --tags
}
