#!/bin/bash

# gitlab merge

set -e

REMOTE="origin"
REMOTE_EXPECTED_URL="gitlab.wikimedia.org"

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
    if grep -Eq ^main$ <<< "$branch" ; then
        return 0
    fi
    return 1
}

if is_main_branch ; then
    echo "E: not operating on the main branch. Doing nothing." >&2
    exit 1
fi

# make sure both branches are up-to-date
git checkout main
gpr
git checkout "$branch"
gpr || true

branch_commit_id=$(git rev-parse "$branch")
common_commit_id=$(git merge-base main "$branch")
if [ "$branch_commit_id" != "$common_commit_id" ] ; then
    echo "E: it seems branch $branch has not been merged to main yet. Doing nothing." >&2
    exit 1
fi

# both branches have the same commit id in common, means the branch was merged to main
git checkout main
git branch --delete --force "$branch"
git remote prune origin
