#!/bin/bash

# github review

set -e

REMOTE="origin"
REMOTE_EXPECTED_URL="github.com"
REMOTE_PERSONAL="aborrero"
BRANCH_PREFIX="arturo-${RANDOM:0:4}-"
BRANCH_MAX_NAME_LENGTH=30


if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] ; then
    echo "E: is this a git repo?" >&2
    exit 1
fi

if [ "$(git status -s | wc -l)" == "0" ] ; then
    echo "W: no uncommited changes, do some edit first. Doing nothing." >&2
    exit 1
fi

remote_url=$(git remote get-url "${REMOTE}")
if [ "${remote_url}" == "" ] ; then
    echo "E: expecting a remote called '${REMOTE}', but couldn't find it. Doing nothing." >&2
    exit 1
fi

if ! grep -q "${REMOTE_EXPECTED_URL}" <<< "${remote_url}" ; then
    echo "E: expected remote URL ${remote_url} to contain ${REMOTE_EXPECTED_URL}, but it doesn't. Doing nothing." >&2
    exit 1
fi

branch=$(git branch --show-current)
is_main_branch() {
    if grep -Eq ^main$\|^master$ <<< "$branch" ; then
        return 0
    fi
    return 1
}

# decide if we need to create a new commit, or refresh a previus one
n_commits="$(git rev-list --count '@{upstream}...HEAD')"
if [ "${n_commits}" == "0" ] ; then
    # create a new commit!
    git add -A

    if is_main_branch ; then
        # this is the first commit for a future PR. Use sign-off
        sign_off="--signoff"
    else
        # not the first commit in the PR. Don't use sign-off because it will leave the github squashed merge commit in bad shape
        sign_off="--no-signoff"
    fi

    git commit "${sign_off}"

    # bump this number so we can relocate the commit later
    n_commits=1
else
    # refresh current commit!
    git add -A
    git commit --amend --no-edit
fi

# decide if we need to create a new branch
if is_main_branch && ! grep -q "${REMOTE_PERSONAL}/" <<< "${remote_url}" ; then
    # we are in main branch, switch!
    string="${BRANCH_PREFIX}$(git show --format=%f | head -1 | tr '[:upper:]' '[:lower:]' | tr . _)"
    # trim length
    string2=${string:0:$BRANCH_MAX_NAME_LENGTH}
    # trim trailing "-" dash character
    new_branch=${string2%-}

    # this relocates commits from the main branch into the new branch
    # see https://stackoverflow.com/questions/1628563/move-the-most-recent-commits-to-a-new-branch-with-git/36463546
    # delete commits from main branch
    git reset --keep HEAD~"${n_commits}"
    # create a new branch
    git checkout --track -B "$new_branch"
    # using reflog, in the new branch, cherry-pick the changes that were in HEAD 2 operations ago
    git cherry-pick ..HEAD@{2}
fi

git push --set-upstream "${REMOTE}" "$new_branch"

# create PR
gh pr create --base $branch --head $new_branch
