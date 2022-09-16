#!/bin/bash

# 0. Constants
POD=busybox
IMAGE=busybox
START_DELAY=2
WORKING_DELAY=5
let LONGER_WORKING_DELAY=$WORKING_DELAY*2
STARTED_FILE=/tmp/started
ALIVE_FILE=/tmp/alive
# 1. Remove old pod e create new one
kubectl delete pod $POD --grace-period 0 --force
kubectl run $POD --image $IMAGE --dry-run=client -o yaml | yq "
.spec.containers[0].args = [\"/bin/sh\",\"-c\",\"touch $ALIVE_FILE; sleep $START_DELAY; touch $STARTED_FILE; sleep $WORKING_DELAY; rm $STARTED_FILE; sleep $LONGER_WORKING_DELAY; touch $STARTED_FILE; sleep $LONGER_WORKING_DELAY; rm $ALIVE_FILE; while true; do sleep 1; done\"],
.spec.containers[0].readinessProbe = {
    \"exec\": { \"command\": [ \"cat\",\"/tmp/started\" ] },
    \"initialDelaySeconds\": 0,
    \"periodSeconds\": 2
},
.spec.containers[0].livenessProbe = {
    \"exec\": { \"command\": [ \"cat\",\"/tmp/started\" ] },
    \"initialDelaySeconds\": 5,
    \"periodSeconds\": 2
}
" | kubectl create -f -

