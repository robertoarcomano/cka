#!/bin/bash

# 0. Constants
POD=busybox
IMAGE=busybox
START_DELAY=10
WORKING_DELAY=10
STARTED_FILE=/tmp/started
# 1. Remove old pod e create new one
kubectl delete pod $POD --grace-period 0 --force
kubectl run $POD --image $IMAGE --dry-run=client -o yaml | yq "
.spec.containers[0].args = [\"/bin/sh\",\"-c\",\"sleep $START_DELAY; touch $STARTED_FILE; sleep $WORKING_DELAY; rm $STARTED_FILE\"]
" | kubectl create -f -

