#!/bin/bash

set -e

BRANCH_PREFIX="arturo-${RANDOM:0:3}-"
BRANCH_MAX_NAME_LENGTH=30

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] ; then
    echo "E: is this a git repo?" >&2
    exit 1
fi

n_commits="$(git rev-list --count '@{upstream}...HEAD')"
if [ "${n_commits}" == "0" ] ; then
    echo "W: no commits. Doing nothing" >&2
    exit 1
fi

# decice if this is a gerrit or a gitlab repo
remotes=$(git remote -v)

# check for a common mistake first
if grep --quiet "aborrero/ansible-setup" <<< "$remotes" ; then
    echo "E: refusing to run in this repo, maybe just use 'git push'" >&2
    exit 1
fi

if grep -Eq gerrit.wikimedia.org\|^gerrit <<< "$remotes" ; then
    # this is a gerrit repository, use git review as usual
    git review -y
    exit $?

elif grep -qE gitlab.wikimedia.org\|github.com <<< "$remotes" ; then
    # this is a gitlab repository
    branch=$(git branch --show-current)

    git_push_args="--force --set-upstream origin"

    # decide if we need to create a new branch
    if grep -Eq ^main$\|^master$ <<< "$branch" ; then
        # we are in main branch, switch!
        string="${BRANCH_PREFIX}$(git show --format=%f | head -1 | tr '[:upper:]' '[:lower:]' | tr . _)"
        # trim length
        string2=${string:0:$BRANCH_MAX_NAME_LENGTH}
        # trim trailing "-" dash character
        branch=${string2%-}

        # this relocates commits from the main branch into the new branch
        # see https://stackoverflow.com/questions/1628563/move-the-most-recent-commits-to-a-new-branch-with-git/36463546
        # delete commits from main branch
        git reset --keep HEAD~${n_commits}
        # create a new branch
        git checkout --track -B "$branch"
        # using reflog, in the new branch, cherry-pick the changes that were in HEAD 2 operations ago
        git cherry-pick ..HEAD@{2}

        # create a new gitlab MR, see
        # https://docs.gitlab.com/ee/user/project/push_options.html
        label="Needs review"
        git_push_args="--push-option=merge_request.create --push-option=merge_request.label=\"${label}\" ${git_push_args}"
    fi

    eval git push "$git_push_args" "$branch"
else
    echo "E: unknown context, expecting gerrit or gitlab" >&2
    exit 1
fi
