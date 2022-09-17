#!/bin/bash

# 0. Constants
NS=project-tiger
DEPLOY=deploy-important

# 1. Delete deploy as well as ns
kubectl delete deploy $DEPLOY -n $NS --grace-period 0 --force
kubectl delete ns $NS --grace-period 0 --force
echo

# 2. Create ns
kubectl create ns $NS

# 3. Create ds
kubectl create -f deploy.yaml

# 4. Check ds
# Wait until ready
until kubectl get pods -n $NS|grep $DEPLOY|grep "Running" -c|grep 2; do sleep 1; done
kubectl get pods -n $NS -o wide |grep $DEPLOY
