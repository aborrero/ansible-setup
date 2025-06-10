#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only

set -e

# git web open
source $(dirname "${BASH_SOURCE[0]}")/arturo-git-lib.sh 2>/dev/null || source /usr/local/share/arturo-git-lib.sh

assert_is_inside_git_repo
remotes=$(get_remotes)
assert_github_or_gitlab_remotes "$remotes"

scheme="https"
origin_url=$(git config --get remote.origin.url)
url=$(sed -e 's/git@//' -e 's/github.com:/github.com\//' -e 's/\.git$//' -e 's/cg-github/github/' <<< $origin_url)

xdg-open "${scheme}://${url}"
