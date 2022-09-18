#!/bin/bash

# 0. Constants
POD_FILE=pod.yaml
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')
STATIC_POD_DIR=/etc/kubernetes/manifests
STATIC_POD_NAME=my-static-pod
SERVICE_NAME=static-pod-service

# 1. Set static pod
scp $POD_FILE root@$MASTER:$STATIC_POD_DIR

# 2. Wait for it to be ready
until kubectl get pods |grep $STATIC_POD_NAME|grep Running -c|grep 1; do sleep 1; done

# 3. Check it and get its actual name
kubectl get pods |grep $STATIC_POD_NAME
STATIC_POD_ACTUAL_NAME=$(kubectl get pods |grep $STATIC_POD_NAME|awk '{print $1}')

# 4. Re-Create the service
kubectl delete svc $SERVICE_NAME
kubectl expose pod "$STATIC_POD_ACTUAL_NAME" --name $SERVICE_NAME --port 80 --type NodePort
sleep 2

# 5. Get the port and test the service
PORT=$(kubectl get svc $SERVICE_NAME --no-headers | awk '{print $5}' |  awk -F":" '{print $2}' |  awk -F"/" '{print $1}')
wget http://$MASTER:$PORT -O-

