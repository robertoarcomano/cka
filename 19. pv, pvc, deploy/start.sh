#!/bin/bash

# 0. Constants

# 1. remove pv, pvc and deploy
kubectl delete -f pv.yaml,pvc.yaml,deploy.yaml --grace-period=0 --force

# 2. create pv, pvc, deploy
kubectl create -f pv.yaml,pvc.yaml,deploy.yaml