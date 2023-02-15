#!/bin/bash

# From: https://git.sr.ht/~taavi/dotfiles/tree/master/item/bin/wmf-update-known-hosts-wmcs

# Update WMCS known hosts
# Based on https://gerrit.wikimedia.org/r/plugins/gitiles/operations/debs/wmf-sre-laptop/+/refs/heads/master/scripts/wmf-update-known-hosts-production
# Copyright (c) 2017 Riccardo Coccioli <rcoccioli@wikimedia.org>
# Copyright (c) 2022 Taavi Väänänen <hi@taavi.wtf>
# License: GPLv3+

set -e

KNOWN_HOSTS_PATH="${HOME}/.ssh/known_hosts.d"
KNOWN_HOST_FILE="${KNOWN_HOSTS_PATH}/wmf-cloud"
KNOWN_HOST_URLS="https://tools-static.wmflabs.org/admin/fingerprints/known_hosts.ecdsa https://toolsbeta-static.wmcloud.org/admin/fingerprints/known_hosts.ecdsa https://config-master.wikimedia.beta.wmflabs.org/known_hosts.ecdsa"

if [[ ! -d "${KNOWN_HOSTS_PATH}" ]]; then
    echo "ERROR: KNOWN_HOSTS_PATH '${KNOWN_HOSTS_PATH}' is not a directory, you might want to adjust the constant in the script or create it"
    exit 1
fi

echo "" > "${KNOWN_HOST_FILE}.new"

# Get new known hosts
for URL in $KNOWN_HOST_URLS
do
    echo "===> Fetching from ${URL}"
    curl "${URL}" >> "${KNOWN_HOST_FILE}.new"
done

sed -i 's/.wmflabs/1.wikimedia.cloud/g' "${KNOWN_HOST_FILE}.new"

PREV_COUNT=0
PREV_FILE=/dev/null
if [[ -f "${KNOWN_HOST_FILE}" ]]; then
    PREV_COUNT="$(wc -l "${KNOWN_HOST_FILE}")"
    PREV_FILE="${KNOWN_HOST_FILE}"
fi

echo "==== DIFFERENCES ===="
colordiff --fakeexitcode "${PREV_FILE}" "${KNOWN_HOST_FILE}.new"
echo "====================="
echo "Going from ${PREV_COUNT} to $(wc -l "${KNOWN_HOST_FILE}.new") known hosts and services"

if [[ -f "${KNOWN_HOST_FILE}" ]]; then
    mv -vf "${KNOWN_HOST_FILE}" "${KNOWN_HOST_FILE}.old"
    echo "Backup file is ${KNOWN_HOST_FILE}.old"
fi

mv -v "${KNOWN_HOST_FILE}.new" "${KNOWN_HOST_FILE}"
echo "New file generated at ${KNOWN_HOST_FILE}"

exit 0
