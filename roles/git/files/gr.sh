#!/bin/bash

set -e

BRANCH_MAX_NAME_LENGTH=30

if ! ls .git/config >/dev/null 2>&1 ; then
    echo "E: missing .git/config file, is this a git repo?" >&2
    exit 1
fi

if [ "$(git status -s | wc -l)" != "0" ] ; then
    echo "E: refusing to work with uncommited changes. Commit first." >&2
    exit 1
fi

if [ "$(git rev-list --count '@{upstream}...HEAD')" == "0" ] ; then
    echo "W: no commits. Doing nothing" >&2
    exit 1
fi

# decice if this is a gerrit or a gitlab repo
remotes=$(git remote -v)
if grep -Eq gerrit.wikimedia.org\|^gerrit <<< "$remotes" ; then
    # this is a gerrit repository, use git review as usual
    git review -y
    exit $?

elif grep -q gitlab.wikimedia.org <<< "$remotes" ; then
    # this is a gitlab repository
    branch=$(git branch --show-current)

    # decide if we need to create a new branch
    if grep -Eq ^main$\|^master$ <<< "$branch" ; then
        # we are in main branch, switch!
        string="$(git show --format=%f | head -1 | tr '[:upper:]' '[:lower:]')"
        branch=${string:0:$BRANCH_MAX_NAME_LENGTH}
        git checkout --track -B "$branch"
    fi

    git push --force -u origin "$branch"
    exit $?

else
    echo "E: unknown context, expecting gerrit or gitlab" >&2
    exit 1
fi
