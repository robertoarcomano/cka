#!/bin/bash

# Requirements: remember to deploy a metric server

# 0. Constants
DEPLOY=nginx
HPA=$DEPLOY
IMAGE=nginx:1.20
NUM_REPLICAS1=2
NUM_REPLICAS2=10
MIN_NUM_REPLICAS=1
MAX_NUM_REPLICAS=20

# functions
function show_replicas {
  kubectl rollout status deploy $DEPLOY
  echo
}

# 1. Create deploy
# 1.1. Delete previous deploy
kubectl delete deploy $DEPLOY
# 1.2. Create deploy with $NUM_REPLICAS1
kubectl create deploy $DEPLOY --image $IMAGE --replicas $NUM_REPLICAS1
show_replicas

# 2. Scale to $NUM_REPLICAS2
kubectl scale deploy $DEPLOY --replicas $NUM_REPLICAS2
show_replicas

# 3. Autoscale from $MIN_NUM_REPLICAS to $MAX_NUM_REPLICAS
kubectl delete hpa $HPA
kubectl autoscale deployment nginx --min $MIN_NUM_REPLICAS --max $MAX_NUM_REPLICAS
kubectl get deploy $DEPLOY -o yaml | yq \
'.spec.template.spec.containers[0].resources.requests.cpu="0.1" |
 .spec.template.spec.containers[0].resources.limits.cpu="1"' | kubectl apply -f -
kubectl get hpa $HPA -w
