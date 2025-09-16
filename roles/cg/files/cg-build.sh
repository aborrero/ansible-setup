#!/bin/bash

set -e
set -o pipefail

PKG=$1

mkdir -p ${PKG}
gh auth token > ${PKG}/.github-token
make debug/${PKG}
make test-debug/${PKG}
