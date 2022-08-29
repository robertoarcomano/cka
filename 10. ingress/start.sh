#!/bin/bash

# 0. Constants
DEPLOY1=nginx
DEPLOY2=httpd
IMAGE1=$DEPLOY1
IMAGE2=$DEPLOY2
SVC1=svc-$DEPLOY1
SVC2=svc-$DEPLOY2
PORT=80
NUM_REPLICAS=2
INGRESS=ingress1
INGRESS_CLASS=nginx

# 0. Requirements
#install metallb
#helm repo add nginx-stable https://helm.nginx.com/stable
#helm repo update
#helm install ingress-nginx nginx-stable/nginx-ingress

# 1. Create deploys
kubectl delete deploy $DEPLOY1 $DEPLOY2
kubectl create deploy $DEPLOY1 --image $IMAGE1 --replicas $NUM_REPLICAS
kubectl create deploy $DEPLOY2 --image $IMAGE2 --replicas $NUM_REPLICAS

# 2. Expose deploy as well as create LB service
kubectl delete svc $SVC1 $SVC2
kubectl expose deploy $DEPLOY1 --name $SVC1 --port $PORT --target-port $PORT
kubectl expose deploy $DEPLOY2 --name $SVC2 --port $PORT --target-port $PORT

# 3. Create ingress
kubectl delete ingress $INGRESS
kubectl create ingress $INGRESS \
  --class $INGRESS_CLASS \
  --rule "public1.robertoarcomano.com/*=$SVC1:$PORT" \
  --rule "public2.robertoarcomano.com/*=$SVC2:$PORT"

# 4. Wait for replicas starting
kubectl rollout status deploy $DEPLOY1
kubectl rollout status deploy $DEPLOY2

# 5. Ingress test
wget http://public1.robertoarcomano.com -O - -q
wget http://public2.robertoarcomano.com -O - -q
