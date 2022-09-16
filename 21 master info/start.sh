#!/bin/bash
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')
MANIFEST_DIR=/etc/kubernetes/manifests

# 1. Check processes
ssh root@"$MASTER" find /etc/systemd/system/ | grep kube
echo

# 2. Check static pods
ssh root@"$MASTER" find $MANIFEST_DIR | grep yaml
echo

# 3. Check running pods on the master
kubectl get pods -A|grep "$MASTER"
echo

# 4. Check dns service
kubectl get all -A|grep -i dns
