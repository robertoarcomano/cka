#!/bin/bash

# 0. Constants

# 1. Delete deploy as well as ns
kubectl replace -f pod.yaml --grace-period 0 --force
echo

# 2. Check ds
# Wait until ready
until kubectl get pod multi-container-playground | grep "Running" -c|grep 1; do sleep 1; done
