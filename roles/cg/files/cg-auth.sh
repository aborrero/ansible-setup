#!/bin/bash

set -e

cmd() {
    local cmd="$@"
    echo "--------------"
    echo "--- $cmd"
    echo "--------------"

    eval "$cmd"
}

cmd gh auth login
cmd chainctl auth login
cmd chainctl auth login --audience=apk.cgr.dev
cmd chainctl auth configure-docker
cmd gcloud auth login
cmd gcloud auth login --update-adc
