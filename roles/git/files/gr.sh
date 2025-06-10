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
    create_mr_branch $n_commits
    current_branch=$(get_current_branch)
else
    current_branch=$orig_branch
    echo "I: guessing original branch as 'main'"
    orig_branch="main"
fi

git_push_mr_branch "$remotes" "$current_branch"

if is_remote_github "$remotes" ; then
    gh pr create --base $orig_branch --head "$current_branch"
fi
