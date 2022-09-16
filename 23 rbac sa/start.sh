#!/bin/bash

# 0. Constants
SA=processor
NS=project-hamster
ROLE=$SA
ROLEBINDING=$ROLE

# 0. Delete rolebinding, sa, role, ns
kubectl delete rolebinding -ns $NS $ROLEBINDING --grace-period 0 --force
kubectl delete sa $SA --grace-period 0 --force
kubectl delete role $ROLE --grace-period 0 --force
kubectl delete ns $NS --grace-period 0 --force
echo

# 1. Create NS as well as SA
kubectl create ns $NS
kubectl create sa $SA -n $NS

# 2. Create Role as well as RoleBinding
kubectl create role -n $NS $ROLE --verb "create" --resource "secrets,configmaps"
kubectl create rolebinding -n $NS $ROLEBINDING  --role=$ROLE --serviceaccount $NS:$SA
