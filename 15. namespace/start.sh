#!/bin/bash

# 0. Constants
NAMESPACE=my-namespace
DEPLOY=nginx
IMAGE=$DEPLOY
REPLICAS=10
PORT=80
SERVICE=$DEPLOY
TIMEOUT=10

# 1. Delete/Create $NAMESPACE namespace
kubectl delete namespace $NAMESPACE --grace-period 0 --force > /dev/null 2>&1
kubectl create namespace $NAMESPACE

# 2. Create deploy on $NAMESPACE namespace
kubectl delete deploy $DEPLOY -n $NAMESPACE --grace-period 0 --force > /dev/null 2>&1
kubectl create deploy $DEPLOY --image $IMAGE --replicas $REPLICAS -n $NAMESPACE

# 3. Expose port $PORT on deploy $DEPLOY
kubectl delete svc $SERVICE -n $NAMESPACE --grace-period 0 --force > /dev/null 2>&1
kubectl expose deploy $DEPLOY --port $PORT -n $NAMESPACE
kubectl rollout status deploy $DEPLOY

# 4. Show objects in $NAMESPACE
kubectl get all -n $NAMESPACE

# 5. Run wget through busybox
kubectl run busybox --image busybox -- wget http://nginx.my-namespace -O -

# 6. Wait a while for busybox to come out
until kubectl get pod busybox -o yaml|yq -C '.status.phase'|grep Running; do echo -n "."; sleep 1; done

# 7. Show logs with a timeout
timeout $TIMEOUT kubectl logs busybox -f

# 8. Remove busybox
kubectl delete pod busybox --grace-period 0 --force > /dev/null 2>&1

# 9. Remove namespace
kubectl delete namespace my-namespace --grace-period 0 --force > /dev/null 2>&1


