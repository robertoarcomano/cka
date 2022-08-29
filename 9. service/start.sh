#!/bin/bash

# 0. Constants
POD=nginx
POD_IMAGE=$POD
PORT=80
DEPLOY=$POD
DEPLOY_IMAGE=$DEPLOY
SERVICE_TYPE=NodePort
SERVICE_NAME=svc-$POD
NUM_REPLICAS=10

# 1. Create configmaps
# 1.0. Delete previous configmap
kubectl delete svc $POD
kubectl delete pod $POD

# 1.1. Create pod $POD
kubectl run $POD --image $POD_IMAGE --expose --port $PORT

# 1.2. Create deploy $DEPLOY
kubectl delete deploy $DEPLOY
kubectl create deploy $DEPLOY --image $DEPLOY_IMAGE --replicas $NUM_REPLICAS

# 1.3. Expose deploy $DEPLOY
kubectl delete svc $SERVICE_NAME
kubectl expose deploy $DEPLOY --name $SERVICE_NAME --port $PORT --target-port $PORT --type $SERVICE_TYPE

# 1.4. Wait for replicas starting
kubectl rollout status deploy $DEPLOY

# 1.5. Generic check
kubectl get all

# 1.6. Test NodePort on all hosts
NODE_PORT=$(kubectl get svc svc-nginx -o yaml|yq ".spec.ports[0].nodePort")
kubectl get nodes -o yaml|yq ".items[].metadata.name"|while read H; do
  echo "*********************************************************************"
  echo "Node: $H"
  echo "*********************************************************************"
  wget -q http://$H:$NODE_PORT -O -;
  echo
done

