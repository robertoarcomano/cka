#!/bin/bash

# 0. Constants
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')
FILENAME=etcd.db
ENDPOINT=127.0.0.1:2379
POD=temp
IMAGE=nginx
NEW_ETCD_DIR=/var/lib/etcd1
ETCD_YAML_PATH=/etc/kubernetes/manifests/etcd.yaml

# 0. Remove pod
ssh root@$MASTER rm -rf $NEW_ETCD_DIR
kubectl delete pod $POD --grace-period=0 --force
sleep 2

# 1. Save
ssh root@$MASTER ETCDCTL_API=3 etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --endpoints=$ENDPOINT \
  snapshot save $FILENAME

# 2. create a pod
kubectl run $POD --image $IMAGE

# 3. check for the pod to become ready
until kubectl get pod $POD|grep -c Running|grep 1; do sleep 1; done

# 4. Restore backup
ssh root@$MASTER ETCDCTL_API=3 etcdctl \
  --data-dir=$NEW_ETCD_DIR \
   snapshot restore $FILENAME

# 5. Get etcd.yaml, Change path and put etcd.yaml
scp root@$MASTER:$ETCD_YAML_PATH .
sed -ri "s/path: \/var\/lib\/etcd/path: \/var\/lib\/etcd1/" etcd.yaml
scp etcd.yaml root@$MASTER:$ETCD_YAML_PATH

# 6. Check for pod
kubectl get pod $POD -w
