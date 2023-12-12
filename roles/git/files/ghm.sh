#!/bin/bash

# github merge

set -e

REMOTE="origin"
REMOTE_EXPECTED_URL="github.com"

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] ; then
    echo "E: is this a git repo?" >&2
    exit 1
fi

if [ "$(git status -s | wc -l)" != "0" ] ; then
    echo "W: uncommited changes. Doing nothing." >&2
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

if is_main_branch ; then
    # simplest case

    git pull --rebase
    git remote prune origin
    exit
fi

# merged branch?
git checkout main
git pull --rebase
git branch --delete --force "$branch"
git remote prune origin
