#!/bin/bash

# gitsign credentials cache helper

set -e

url=$(journalctl --user -u gitsign-credential-cache.service | tail -1 | awk -F' ' '{print $6}')
pattern="^https:\/\/oauth2\.sigstore\.dev\/auth\/auth\?access_type=online&client_id=sigstore&code_challenge=[A-Za-z0-9_-]+&code_challenge_method=S256&connector_id=https%3A%2F%2Faccounts\.google\.com&nonce=[A-Za-z0-9]+&redirect_uri=http%3A%2F%2Flocalhost%3A[0-9]+%2Fauth%2Fcallback&response_type=code&scope=openid\+email&state=[A-Za-z0-9]+$"

if ! grep -qE "$pattern" <<< "${url}" ; then
    echo "WARNING: this script is quick and dirty and has limitations :-P" >&2
    echo "WARNING: unexpected gitsign-credential-cache URL:" >&2
    echo "$url"
    exit 1
fi

xdg-open "$url"
