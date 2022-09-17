#!/bin/bash

# 0. Constants

# 1. Delete deploy as well as ns
kubectl replace -f pod.yaml --grace-period 0 --force
echo

# 2. Wait until ready
until kubectl get pod multi-container-playground | grep "Running" -c|grep 1; do sleep 1; done

# 3. Checks output
kubectl exec -it multi-container-playground -c c1 -- env|grep MY_NODE_NAME
kubectl exec -it multi-container-playground -c c2 -- ps xal|grep "date >> "|grep -v grep
kubectl logs multi-container-playground -c c3

