#!/bin/bash

# git refresh current patch, in either stgit or raw commit mode

set -e

source $(dirname "${BASH_SOURCE[0]}")/arturo-git-lib.sh 2>/dev/null || source /usr/local/share/arturo-git-lib.sh

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

assert_is_inside_git_repo
assert_some_changes

branch=$(get_current_branch)
n_commits=$(get_commit_count)

if is_main_branch "$branch" && [ "${n_commits}" == "0" ] ; then
    if [ "$force" == "yes" ] ; then
        echo "I: force refresh last commit for a later force push of a main branch"
    else
        echo "E: updates for a later force push to the main branch is not usually done, doing nothing. Try '--force'" >&2
        exit 1
    fi
fi

run_gscc_in_background_if_required

if [ "$(stg top 2>/dev/null | wc -l)" == "1" ] ; then
    # stgit context!
    stg refresh
    exit $?
else
    # raw commit context!
    git add -A
    git commit --amend --no-edit
    exit $?
fi
