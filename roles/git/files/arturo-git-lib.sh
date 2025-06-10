# SPDX-License-Identifier: GPL-3.0-only

BRANCH_PREFIX="arturo-${RANDOM:0:3}-"
BRANCH_MAX_NAME_LENGTH=30

assert_is_inside_git_repo() {
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] ; then
        echo "E: is this a git repo?" >&2
        exit 1
    fi
}

assert_some_commits() {
    local n_commits=$1
    if [ "${n_commits}" == "0" ] ; then
        echo "W: no commits. Doing nothing" >&2
        exit 1
    fi
}

assert_remote_is_not_aborrero_ansible_setup() {
    local remotes=$1
    if grep --quiet "aborrero/ansible-setup" <<< "$remotes" ; then
        echo "E: refusing to run in this repo, maybe just use 'git push'" >&2
        exit 1
    fi
}

assert_github_or_gitlab_remotes() {
    local remotes="$1"
    if is_remote_gitlab "$remotes" ; then
        return
    fi
    if is_remote_github "$remotes" ; then
        return
    fi
    echo "E: unknown context, expecting gerrit or gitlab" >&2
    exit 1
}

get_commit_count() {
    git rev-list --count '@{upstream}...HEAD'
}

get_remotes() {
    git remote -v
}

get_current_branch() {
    git branch --show-current
}

is_remote_that_uses_git_review() {
    local remotes=$1
    if grep -Eq ^gerrit <<< "$remotes" ; then
        return 0
    fi
    return 1
}

is_remote_gitlab() {
    local remotes=$1
    if grep -qE gitlab.wikimedia.org\|salsa.debian.org\|gitlab.com <<< "$remotes" ; then
        return 0
    fi
    return 1
}

is_remote_github() {
    local remotes=$1
    if grep -qE github.com <<< "$remotes" ; then
        return 0
    fi
    return 1
}

is_main_branch() {
    local branch=$1
    if grep -Eq ^main$\|^master$ <<< "$branch" ; then
        return 0
    fi
    return 1
}

create_mr_branch() {
    local n_commits=$1

    local string="${BRANCH_PREFIX}$(git show --format=%f | head -1 | tr '[:upper:]' '[:lower:]' | tr . _)"
    # trim length
    local string2=${string:0:$BRANCH_MAX_NAME_LENGTH}
    # trim trailing "-" dash character
    local branch=${string2%-}

    # this relocates commits from the main branch into the new branch
    # see https://stackoverflow.com/questions/1628563/move-the-most-recent-commits-to-a-new-branch-with-git/36463546
    # delete commits from main branch
    git reset --keep HEAD~${n_commits}
    # create a new branch
    git checkout --track -B "$branch"
    # using reflog, in the new branch, cherry-pick the changes that were in HEAD 2 operations ago
    git cherry-pick ..HEAD@{2}
}

git_push_mr_branch() {
    local remotes="$1"
    local mr_branch="$2"
    local git_push_args="--force --set-upstream origin"


    if is_remote_gitlab "$remotes" ; then
       # create a new gitlab MR, see
       # https://docs.gitlab.com/ee/user/project/push_options.html
       label="Needs review"
       git_push_args="--push-option=merge_request.create --push-option=merge_request.label=\"${label}\" ${git_push_args}"
    fi

    eval git push "$git_push_args" "$mr_branch"
}
