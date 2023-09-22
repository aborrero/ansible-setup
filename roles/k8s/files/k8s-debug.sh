#!/bin/bash

# run a Debian debug container inside local kubernetes
# see also:
# https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container

NAME="debug"
IMAGE="debian:bookworm"

kubectl run debug --image=registry.k8s.io/pause:3.1 --restart=Never
kubectl debug -it ${NAME} --image=${IMAGE} --target=${NAME}
