#!/bin/bash

# git refresh current patch, in either stgit or raw commit mode

set -e

arg=$1

if [ -n "$arg" ] ; then
    if [ "$arg" == "-h" ] || [ "$arg" == "--help" ] ; then
        echo "I: use --force to allow rewriting last commit in main branch for a later force-push"
        exit 0
    fi
    if [ "$arg" == "--force" ] ; then
        force="yes"
    fi
fi

if ! ls .git/config >/dev/null 2>&1 ; then
    echo "E: missing .git/config file, is this a git repo?" >&2
    exit 1
fi

if [ "$(git status -s | wc -l)" == "0" ] ; then
    echo "W: no uncommited changes, do some edit first" >&2
    exit 1
fi

branch=$(git branch --show-current)

if grep -Eq ^main$\|^master$ <<< "$branch" && [ "$(git rev-list --count '@{upstream}...HEAD')" == "0" ] ; then
    if [ "$force" == "yes" ] ; then
        echo "I: force refresh last commit for a later force push of a main branch"
    else
        echo "E: updates for a later force push to the main branch is not usually done, doing nothing. Try '--force'" >&2
        exit 1
    fi
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
