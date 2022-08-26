#!/bin/bash

# 0. Constants
CONFIGMAP1=cm1
CONFIGMAP2=cm2
CONFIGMAP3=cm3

## functions
#function show_replicas {
#  kubectl rollout status deploy $DEPLOY
#  echo
#}

# 1. Create configmap
# 1.1. Delete previous configmap
kubectl delete cm $CONFIGMAP1
# 1.2. Create $CONFIGMAP1
kubectl create cm $CONFIGMAP1 --from-literal "user=roberto" --from-literal "city=Turin"

