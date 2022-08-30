#!/bin/bash
#
## 0. Constants
NODE1=w1.robertoarcomano.com
NODE2=w2.robertoarcomano.com
KEY=slow
VALUE=true
EFFECT=NoSchedule
DEPLOY_NAME1=nginx
DEPLOY_IMAGE1=$DEPLOY_NAME1
REPLICAS=10
DEPLOY_NAME2=httpd
DEPLOY_IMAGE2=$DEPLOY_NAME2

# 1. Taint NODE1
kubectl taint node $NODE1 $KEY=$VALUE:$EFFECT-
kubectl taint node $NODE1 $KEY=$VALUE:$EFFECT
kubectl describe node $NODE1|grep -e Taint -e Name:

# 1. Create Deploy $DEPLOY_NAME1
kubectl delete deploy $DEPLOY_NAME1 --grace-period 0 --force 1>/dev/null 2>&1
kubectl create deploy $DEPLOY_NAME1 --image $DEPLOY_IMAGE1 --replicas $REPLICAS

# 2. Wait until final status is reached
until kubectl get pods -l "app=$DEPLOY_NAME1" -o yaml | yq -C ".items[].spec.nodeName"| grep -c $NODE2 |grep $REPLICAS; do sleep 1; done
echo "All $REPLICAS replicas on node $NODE2"

## 3. Create Deploy $DEPLOY_NAME2
kubectl delete deploy $DEPLOY_NAME2 --grace-period 0 --force 1>/dev/null 2>&1
kubectl create deploy $DEPLOY_NAME2 --image $DEPLOY_IMAGE2 --replicas $REPLICAS --dry-run=client -o yaml | yq "
.spec.template.spec.tolerations=[ {\"key\": \"$KEY\", \"operator\": \"Equal\", \"value\": \"$VALUE\", \"effect\": \"$EFFECT\" } ]
" | kubectl apply -f -

# 4. Wait until final status is reached
until kubectl get pods -l "app=$DEPLOY_NAME2" -o wide|grep -c Running|grep $REPLICAS; do sleep 1; done

# 5. Show list of pods and nodes
kubectl get pods -l "app=$DEPLOY_NAME2" -o wide

# 6. Remove the taint
kubectl taint node $NODE1 $KEY=$VALUE:$EFFECT-
