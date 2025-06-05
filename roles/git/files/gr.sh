#!/bin/bash

set -e

source $(dirname "${BASH_SOURCE[0]}")/arturo-git-lib.sh 2>/dev/null || source /usr/local/share/arturo-git-lib.sh

assert_is_inside_git_repo
n_commits=$(get_commit_count)
assert_some_commits $n_commits
remotes=$(get_remotes)
assert_remote_is_not_aborrero_ansible_setup "$remotes"


if is_remote_that_uses_git_review "$remotes"; then
    # this is a gerrit repository, use git review as usual
    git review -y
    exit $?
fi

assert_github_or_gitlab_remotes "$remotes"

orig_branch=$(get_current_branch)
if is_main_branch $orig_branch ; then
    mr_branch=$(create_mr_branch $n_commits)
fi

git_push_mr_branch "$remotes" $mr_branch

if is_remote_github "$remotes" ; then
    if is_main_branch $orig_branch ; then
        base_branch=$orig_branch
    else
        base_branch="main"
        mr_branch=$orig_branch
    fi
    gh pr create --base $base_branch --head $mr_branch
fi
