#!/bin/bash

# git refresh current patch, in either stgit or raw commit mode

set -e

if ! ls .git/config >/dev/null 2>&1 ; then
    echo "E: missing .git/config file, is this a git repo?" >&2
    exit 1
fi

if [ "$(git status -s | wc -l)" == "0" ] ; then
    echo "W: no uncommited changes, do some edit first" >&2
    exit 1
fi

branch=$(git branch --show-current)

if grep -Eq main\|master <<< "$branch" && [ "$(git rev-list --count '@{upstream}...HEAD')" == "0" ] ; then
    echo "E: updates for a later force push to the main branch is not usually done, doing nothing" >&2
    exit 1
fi

if git branch -l | grep -q "$branch".stgit && [ "$(stg top 2>/dev/null | wc -l)" == "1" ] ; then
    # stgit context!
    stg refresh
    exit $?
else
    # raw commit context!
    git add -A
    git commit --amend --no-edit
    exit $?
fi
