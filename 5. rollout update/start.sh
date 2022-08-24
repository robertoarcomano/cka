#!/bin/bash

# 0. Constants
DEPLOY=nginx
CONTAINER=$DEPLOY
IMAGE1=nginx:1.17
IMAGE2=nginx:1.18
IMAGE3=nginx:1.19
IMAGE4=nginx:1.20
NUM_REPLICAS=2

# functions
function show_version {
  RET=$(kubectl get deploy $DEPLOY -o yaml | yq '.spec.template.spec.containers[0].image')
  echo "$DEPLOY present version: $RET"
  kubectl rollout status deploy $DEPLOY
  echo
}

# 1. Create deploy
# 1.1. Delete previous deploy
kubectl delete deploy $DEPLOY #--grace-period 0 --force
# 1.2. Create deploy with image1 and replicas
kubectl create deploy $DEPLOY --image $IMAGE1 --replicas $NUM_REPLICAS
show_version

# 2. Change version from 17 to 18 using "set image" command
kubectl set image deploy $DEPLOY $CONTAINER=$IMAGE2 --record 2>/dev/null
show_version

# 3. Change version from $IMAGE2 to $IMAGE3 using saving yaml, updating and applying it
kubectl get deploy $DEPLOY -o yaml | sed -r "s/image: $IMAGE2/image: $IMAGE3/g" | kubectl apply -f - 2>/dev/null
show_version

# 4. Go from $IMAGE3 to $IMAGE4 using "rollout undo" command
kubectl set image deploy $DEPLOY $CONTAINER=$IMAGE4 --record 2>/dev/null
show_version

# 5. Go from $IMAGE3 to $IMAGE4 using "rollout undo" command
kubectl rollout undo deploy $DEPLOY --to-revision 2
show_version

# 99. Check rollout history
kubectl rollout history deploy $DEPLOY
