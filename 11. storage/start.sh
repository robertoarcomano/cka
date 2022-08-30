#!/bin/bash

# 0. Constants
PV1_FILE=pv1.yaml
PV1_NAME=pv1
PVC1_FILE=pvc1.yaml
PVC1_NAME=pvc1
PVC1_PATH=/tmp/pvc1
POD1=nginx
IMAGE1=$POD1

PVC2_FILE=pvc2.yaml
PVC2_NAME=pvc2
PVC2_PATH=/tmp/pvc2
POD2=httpd
IMAGE2=$POD2

# 0. Requirements
#helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
#helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
#  --create-namespace \
#  --namespace nfs-provisioner \
#  --set nfs.server=192.168.57.1 \
#  --set nfs.path=/srv/nfs4/backups

kubectl delete pod $POD1 $POD2 --grace-period 0 --force

# 1. Create SC PVC1, PVC2
kubectl delete pvc $PVC1_NAME $PVC2_NAME --grace-period 0 --force
kubectl create -f $PVC1_FILE,$PVC2_FILE

# 2. Create PV
kubectl delete pv $PV1_NAME --grace-period 0 --force
kubectl create -f $PV1_FILE

# 3. Create POD1
kubectl run $POD1 --image $IMAGE1 --dry-run=client -o yaml | yq "
.spec.volumes = [ { \"name\": \"$PVC1_NAME\", \"persistentVolumeClaim\": { \"claimName\": \"$PVC1_NAME\"} } ],
.spec.containers[0].volumeMounts = [ { \"name\": \"$PVC1_NAME\", \"mountPath\": \"$PVC1_PATH\"  } ]
" | kubectl create -f -

# 4. Create POD2
kubectl run $POD2 --image $IMAGE2 --dry-run=client -o yaml | yq "
.spec.volumes = [ { \"name\": \"$PVC2_NAME\", \"persistentVolumeClaim\": { \"claimName\": \"$PVC2_NAME\"} } ],
.spec.containers[0].volumeMounts = [ { \"name\": \"$PVC2_NAME\", \"mountPath\": \"$PVC2_PATH\"  } ]
" | kubectl create -f -

# 5. Wait for POD to become ready
echo "Waiting for pod $POD1 and $POD2 to become ready"
until kubectl get pod $POD1 $POD2 -o yaml|yq ".items[].status.phase"|grep -c Running|grep 2; do echo -n "."; sleep 1; done

# 6. Test pods
kubectl exec $POD1 -- bash -c "df -hT $PVC1_PATH"
kubectl exec $POD2 -- bash -c "df -hT $PVC2_PATH"

