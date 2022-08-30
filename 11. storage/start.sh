#!/bin/bash

# 0. Constants
PV1_FILE=pv1.yaml
PV1_NAME=pv1
PVC1_FILE=pvc1.yaml
PVC1_NAME=pvc1
POD=nginx
IMAGE=$POD
PVC1_PATH=/tmp/pvc1

# 0. Requirements
kubectl delete pod $POD --grace-period 0 --force

# 1. Create PVC
kubectl delete pvc $PVC1_NAME --grace-period 0 --force
kubectl create -f $PVC1_FILE

# 2. Create PV
kubectl delete pv $PV1_NAME --grace-period 0 --force
kubectl create -f $PV1_FILE

# 3. Create POD
kubectl run $POD --image $IMAGE --dry-run=client -o yaml | yq "
.spec.volumes = [ { \"name\": \"$PVC1_NAME\", \"persistentVolumeClaim\": { \"claimName\": \"$PVC1_NAME\"} } ],
.spec.containers[0].volumeMounts = [ { \"name\": \"$PVC1_NAME\", \"mountPath\": \"$PVC1_PATH\"  } ]
" | kubectl create -f -

# 4. Wait for POD to become ready
echo "Waiting for pod $POD to become ready"
until kubectl get pod nginx -o yaml|yq ".status.phase"|grep Running; do echo -n "."; sleep 1; done

# 5. Test PV
kubectl exec $POD -- bash -c "df -hT $PVC1_PATH"
