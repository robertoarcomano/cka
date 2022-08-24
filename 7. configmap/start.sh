#!/bin/bash

# 0. Constants

## functions
#function show_replicas {
#  kubectl rollout status deploy $DEPLOY
#  echo
#}

# 1. Create deploy
# 1.1. Delete previous deploy
kubectl delete deploy $DEPLOY
# 1.2. Create deploy with $NUM_REPLICAS1
kubectl create deploy $DEPLOY --image $IMAGE --replicas $NUM_REPLICAS1
show_replicas
