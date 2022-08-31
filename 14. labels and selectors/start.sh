#!/bin/bash

# 0. Constants
DEPLOY=nginx
IMAGE=$DEPLOY
REPLICAS=2

# 1. Create a deploy
kubectl delete deploy $DEPLOY --grace-period 0 --force
kubectl create deploy $DEPLOY --image $IMAGE --replicas $REPLICAS

# 2. Wait until ready
kubectl rollout status deploy $DEPLOY

# 3. Show deploy label
echo -n "Deploy $DEPLOY label: "
kubectl get deploy $DEPLOY -o yaml|yq -C '.metadata.labels'

# 4. Show RS labels
echo -n "RS $DEPLOY label: "
kubectl get deploy $DEPLOY -o yaml|yq -C '.metadata.labels'

