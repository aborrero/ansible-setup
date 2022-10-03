#!/bin/bash

STG="$(which stg)"
GIT="$(which git)"

set -e

if [ "${USER}" == "root" ] ; then
	echo "E: running as root?" >&2
	exit 1
fi

if [ ! -x "$STG" ] ; then
	echo "E: no stg binary found" >&2
	exit 1
fi

if [ ! -x "$GIT" ] ; then
	echo "E: no git binary found" >&2
	exit 1
fi

$STG pull
$GIT review -y
