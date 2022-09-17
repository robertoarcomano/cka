#!/bin/bash

# 1 Events1
EVENTS1=$(kubectl get events -A --sort-by='.metadata.creationTimestamp')
echo "Events1: $EVENTS1"

# 2 Events2
POD=$(kubectl get pods -A -o wide|grep proxy|grep w1|awk '{print $2}')
echo "killing $POD..."
kubectl delete pod $POD -n kube-system --grace-period=0 --force
EVENTS2=$(kubectl get events -A --sort-by='.metadata.creationTimestamp'|grep proxy)
echo "Events2: $EVENTS2"

# 3. Events3
POD=$(kubectl get pods -A -o wide|grep proxy|grep w1|awk '{print $2}')
echo "POD: $POD"
CONTAINER_ID=$(ssh w1 crictl ps 2>/dev/null |grep $POD|awk '{print $1}')
echo "Container ID: $CONTAINER_ID"
echo "killing Container ID..."
ssh w1 crictl rm -f $CONTAINER_ID
EVENTS3=$(kubectl get events -A --sort-by='.metadata.creationTimestamp'|grep proxy)
echo "Events3: $EVENTS3"

