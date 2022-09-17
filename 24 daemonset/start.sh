#!/bin/bash

# 0. Constants
NS=project-tiger
DS=ds-important

# 1. Delete ds as well as ns
kubectl delete ds $DS -n $NS --grace-period 0 --force
kubectl delete ns $NS --grace-period 0 --force
echo

# 2. Create ns
kubectl create ns $NS

# 3. Create ds
kubectl create -f ds.yaml

# 4. Check ds
kubectl get all -n $NS -o wide