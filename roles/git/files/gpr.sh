#!/bin/bash

# This script runs git pull --rebase, with support for stgit context and github forks

set -e

source $(dirname "${BASH_SOURCE[0]}")/arturo-git-lib.sh 2>/dev/null || source /usr/local/share/arturo-git-lib.sh

assert_is_inside_git_repo

n_stgit_patches="$(stg series -c -A 2>/dev/null || echo 0)"
stg pop -a 2>/dev/null || true

git pull --rebase

# redo stgit patches, if any
if [ "${n_stgit_patches}" != "0" ] ; then
    stg push -m --number="${n_stgit_patches}"
fi
