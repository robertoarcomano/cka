#!/bin/bash

# 0. Constants
CONFIGMAP1=cm1
CONFIGMAP2=cm2
CONFIGMAP3=cm3
ENV_FILE=env-file
FILE=file.json

## functions
#function show_replicas {
#  kubectl rollout status deploy $DEPLOY
#  echo
#}

# 1. Create configmaps
# 1.0. Delete previous configmap
kubectl delete cm $CONFIGMAP1 $CONFIGMAP2 $CONFIGMAP3
# 1.1. Create $CONFIGMAP1
kubectl create cm $CONFIGMAP1 --from-literal "user=roberto" --from-literal "city=Turin"
# 1.2. Create $CONFIGMAP2
kubectl create cm $CONFIGMAP2 --from-env-file $ENV_FILE
# 1.3. Create $CONFIGMAP3
kubectl create cm $CONFIGMAP3 --from-file $FILE
# 1.4. Check
kubectl get cm cm1 cm2 cm3 -o yaml
