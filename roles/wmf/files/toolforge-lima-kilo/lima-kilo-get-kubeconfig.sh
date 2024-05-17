#!/bin/bash

set -e

DIR="${HOME}/.kube"
KUBECONFIG="${DIR}/config"

mkdir -p ~/.kube

if [ -e "${KUBECONFIG}" ] ; then
    # backup
    date=$(date +"%Y%m%d%H%M")
    backup="${DIR}/${date}-config.backup"
    cp "${KUBECONFIG}" "${backup}"
fi

LIMA_KILO_HOME="$(limactl --log-level error shell --workdir / lima-kilo -- printenv HOME)"
content=$(limactl --log-level error shell --workdir "${LIMA_KILO_HOME}" lima-kilo -- cat "${LIMA_KILO_HOME}/.kube/config")

echo "$content"
echo "$content" > "${KUBECONFIG}"
