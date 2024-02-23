#!/bin/bash

# edit current commit message, in either stgit or raw commit mode

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

branch=$(git branch --show-current)

if grep -Eq ^main$\|^master$\|^production$ <<< "$branch" && [ "$(git rev-list --count '@{upstream}...HEAD')" == "0" ] ; then
    if [ "$force" == "yes" ] ; then
        echo "I: force refresh last commit for a later force push of a main branch"
    else
        echo "E: updates for a later force push to the main branch is not usually done, doing nothing. Try '--force'" >&2
        exit 1
    fi
fi

if [ "$(stg top 2>/dev/null | wc -l)" == "1" ] ; then
    # stgit context!
    stg edit
    exit $?
else
    # raw commit context!
    git commit --amend
    exit $?
fi
