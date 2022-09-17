#!/bin/bash

# 0. Constants
POD=tigers-reunite
NS=project-tiger
IMAGE=httpd:2.4.41-alpine

# 1. recreate POD
kubectl delete pod $POD -n $NS --grace-period=0 --force
kubectl run $POD -n $NS --image $IMAGE --labels "pod=container,container=pod"
until kubectl get pod $POD -n $NS|grep Running -c|grep 1; do sleep 1; done

# 2. Retrieve node
NODE=$(kubectl get pod $POD -n $NS --no-headers -o wide|awk '{print $7}')
echo "Node: $NODE"
echo

# 3. Get the container ID
CONTAINER_ID=$(ssh root@$NODE crictl ps 2>/dev/null|grep $POD|awk '{print $1}')
echo "Container ID: $CONTAINER_ID"
echo

# 4. Show info.runtimeType
INFO_RUNTIME_TYPE=$(ssh root@$NODE crictl inspect $CONTAINER_ID 2>/dev/null|yq '.info.runtimeType')
echo "info.runtimeType: $INFO_RUNTIME_TYPE"
echo

# 5. Logs of the container
echo "LOGS:"
ssh root@$NODE crictl logs $CONTAINER_ID
