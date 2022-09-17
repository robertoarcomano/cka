#!/bin/bash

# 0. Constants
NS=cka-master

# 1. Recreate ns
kubectl delete ns $NS --grace-period=0 --force
kubectl create ns $NS

# 2. Show namespaced api-resources
kubectl api-resources --namespaced --no-headers|awk '{print $NF}'

# 3. Namespace with the most roles
kubectl get ns --no-headers|awk '{print $1}'|while read NS; do
  echo $NS " " $(kubectl get roles -n $NS 2>/dev/null|wc -l);
done|sort -n -k 2|tail -1
