#!/bin/bash

# 0. Constants
POD=busybox
IMAGE=busybox

# 1. Remove old pod e create new one
kubectl delete pod $POD --grace-period 0 --force
kubectl run $POD --image $IMAGE --dry-run=client -o yaml | yq '
.spec.containers[0].command = ["/bin/sh","-c","while true; do echo 'ok'; sleep 1; done"]
' | kubectl create -f -

