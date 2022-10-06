#!/bin/bash

# 0. Constants
JOB=job
TIMEOUT=5

# 1. Re-create a job
kubectl delete job $JOB --grace-period 0 --force
kubectl create job $JOB --image busybox -- sh -c "c=0; until [ \$c -gt $TIMEOUT ]; do echo \$c; let c=\$c+1; sleep 1; done"

# 2. Show job
POD=$(kubectl get pods -l "job-name=$JOB" --no-headers|awk '{print $1}')
timeout $TIMEOUT kubectl get pod $POD -w
timeout $TIMEOUT kubectl logs $POD -f

