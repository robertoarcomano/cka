#!/bin/bash

# 0. Constants
CONFIGMAP1=cm1
CONFIGMAP2=cm2
CONFIGMAP3=cm3
ENV_FILE=env-file
FILE=file.json
POD_FILE=nginx.yaml
POD=nginx

## functions
#function show_replicas {
#  kubectl rollout status deploy $DEPLOY
#  echo
#}

# 1. Create configmaps
# 1.0. Delete previous configmap
kubectl delete cm $CONFIGMAP1 $CONFIGMAP2 $CONFIGMAP3
# 1.1. Create $CONFIGMAP1
kubectl create cm $CONFIGMAP1 --from-literal "user=roberto" --from-literal "city=Turin"
# 1.2. Create $CONFIGMAP2
kubectl create cm $CONFIGMAP2 --from-env-file $ENV_FILE
# 1.3. Create $CONFIGMAP3
kubectl create cm $CONFIGMAP3 --from-file $FILE
# 1.4. Check
kubectl get cm cm1 cm2 cm3 -o yaml

# 2. Use configmaps
# 2.0. Delete the pod
kubectl delete pod $POD
# 2.1. Create a pod (dry run) and save it to $POD_FILE
kubectl run $POD --image nginx --dry-run=client -o yaml > $POD_FILE
# 2.2. Add to the pod
cat $POD_FILE | yq '
.spec.volumes[0]={"name": "vol-cm1", "configMap": { "name": "cm1"}},
.spec.containers[0].env = [
  {
    "name": "user",
    "valueFrom": {
      "configMapKeyRef": {
        "name": "cm1",
        "key": "user"
      }
    }
  }
],
.spec.containers[0].envFrom = [
  {
    "configMapRef": {
      "name": "cm2"
    }
  }
]
'|kubectl apply -f -

# 2.3. Sleep until pod is ready
echo "Waiting for the pod to become Running..."
until kubectl get pods nginx|grep Running; do sleep 1; done
# 2.4. Check for cm1
kubectl exec -it nginx -- env | grep -e user -e number -e country
