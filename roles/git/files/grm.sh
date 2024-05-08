#!/bin/bash

# git rebase with main branch

set -e

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] ; then
    echo "E: is this a git repo?" >&2
    exit 1
fi

branch=$(git branch --show-current)

git checkout main
gpr  # custom git pull rebase

if [ "$branch" != "main" ] ; then
    git checkout "$branch"
    git rebase main
fi
