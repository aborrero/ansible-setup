#!/bin/bash

set -e

# This script runs git pull --rebase, with support for stgit context

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] ; then
    echo "E: is this a git repo?" >&2
    exit 1
fi

n_stgit_patches="$(stg series -c -A 2>/dev/null || echo 0)"
stg pop -a 2>/dev/null || true

git pull --rebase

# redo stgit patches, if any
if [ "${n_stgit_patches}" != "0" ] ; then
    stg push -m --number="${n_stgit_patches}"
fi
