#!/bin/bash

kubectl delete pod nginx-block --grace-period 0 --force
kubectl delete pvc pvc-nfs-block
kubectl delete pv pv-nfs-block
#
#kubectl create -f nginx-block.yaml
#kubectl create -f pvc-nfs-block.yaml
#kubectl create -f pv-nfs-block.yaml
#
#
