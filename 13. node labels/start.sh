#!/bin/bash
#
## 0. Constants
NODE1=w1.robertoarcomano.com
REPLICAS=10
DEPLOY_NAME1=nginx
DEPLOY_IMAGE1=$DEPLOY_NAME1
REPLICAS=10

# 1. Remove label node $NODE1
kubectl label node $NODE1 ssd-

# 2. Use nodeSelector
kubectl delete deploy $DEPLOY_NAME1
kubectl create deploy $DEPLOY_NAME1 --image $DEPLOY_IMAGE1 --replicas $REPLICAS --dry-run=client -o yaml|yq '
.spec.template.spec.nodeSelector={"ssd": "1"}
'| kubectl apply -f -

# 3. Wait for roll out
sleep 2

# 4. Show pods
kubectl get pods -l "app=$DEPLOY_IMAGE1" -o wide|grep -e Pending -e NAME

# 5. Label node $NODE1
kubectl label node $NODE1 ssd=1

# 6. Wait until ready
until kubectl get pods -l "app=$DEPLOY_IMAGE1" | grep Running -c | grep $REPLICAS; do sleep 1; done

# 7. Show pods
kubectl get pods -l "app=$DEPLOY_IMAGE1" -o wide