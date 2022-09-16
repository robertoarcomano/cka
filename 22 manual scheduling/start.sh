#!/bin/bash

# 0. Constants
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')
MANIFEST_DIR=/etc/kubernetes/manifests
STATIC_POD=kube-scheduler.yaml
DEST_DIR=/etc/kubernetes
IMAGE=httpd
POD=manual-pod

# 1. Temporary kill the scheduler
ssh root@"$MASTER" mv $MANIFEST_DIR/$STATIC_POD $DEST_DIR

# 2. Create a new pod
kubectl delete pod $POD --grace-period 0 --force
sleep 2
kubectl run $POD --image $IMAGE

# 2.bis Wait until pod is in pending status
until kubectl get pod $POD|grep Pending; do sleep 1; done
sleep 2

# 3. Manual scheduling
kubectl get pod $POD -o yaml | \
  yq '.spec.nodeName="w1.robertoarcomano.com"' | \
  kubectl replace -f - --force

# 3bis. Check sched status
kubectl get pod $POD
until kubectl get pod $POD|grep Running; do sleep 1; done

# 4. Restart the scheduler
ssh root@"$MASTER" mv $DEST_DIR/$STATIC_POD $MANIFEST_DIR/

# 5. Remove the pod
kubectl delete pod $POD --grace-period=0 --force