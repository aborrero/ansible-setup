#!/bin/bash

# git rebase with main branch

set -e

source $(dirname "${BASH_SOURCE[0]}")/arturo-git-lib.sh 2>/dev/null || source /usr/local/share/arturo-git-lib.sh

PRIMARY_BRANCH="main"

assert_is_inside_git_repo

branch=$(get_current_branch)

run_gscc_in_background_if_required

git checkout $PRIMARY_BRANCH
gpr  # custom git pull rebase

if [ "$branch" != "${PRIMARY_BRANCH}" ] ; then
    git checkout "$branch"
    git rebase $PRIMARY_BRANCH
fi
