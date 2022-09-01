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
echo

# 3. Show deploy label
echo "Deploy $DEPLOY label: "
kubectl get deploy -l "app=$DEPLOY" -o yaml|yq -C '.items[].metadata.labels'
echo

# 4. Show replicaset label
echo "ReplicaSets label: "
kubectl get rs -l "app=$DEPLOY" -o yaml|yq -C '"name: " + .items[].metadata.name, .items[].metadata.labels'
echo

# 5. Show pods label
echo "Pod label: "
kubectl get pods -l "app=$DEPLOY" -o yaml|yq -C '"name: " + .items[].metadata.name, .items[].metadata.labels'
echo

# 6. Create Annotation
kubectl annotate deploy $DEPLOY "Purpose=used to show the correlation among deploy, replicasets and pods"

# 5. Show Annotation
kubectl get deploy $DEPLOY -o yaml|yq -C '.metadata.annotations'