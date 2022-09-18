#!/bin/bash

# 0. Constants
NS=secret
POD=secret-pod
IMAGE=busybox:1.31.1
SECRET1_NAME=secret1
SECRET1_FILE=secret1.yaml
SECRET1_MOUNT_POINT=/tmp/secret1
SECRET2=secret2

# 1. Delete secrets
kubectl delete -f $SECRET1_FILE --grace-period 0 --force 2>/dev/null
kubectl delete -n $NS $SECRET2 --grace-period 0 --force 2>/dev/null

# 2. Delete the pod
kubectl delete pod $POD -n $NS --grace-period 0 --force 2>/dev/null

# 3. Delete the NS
kubectl delete ns $NS --grace-period 0 --force 2>/dev/null

# 4. Create the NS
kubectl create ns $NS

# 5. Create the POD
kubectl run $POD --image $IMAGE -n $NS -- sh -c "while true; do echo 1; sleep 1; done"

# 6. Create secret1
kubectl create -f secret1.yaml

# 7. Mount secret1 into the pod
kubectl get pod $POD -n $NS -o yaml | yq "
.spec.volumes=[
  {
    \"name\": \"secret-vol\",
    \"secret\": { \"secretName\": \"$SECRET1_NAME\"}
  }
],
.spec.containers[0].volumeMounts=[
  {
    \"name\": \"secret-vol\",
    \"readOnly\": true,
    \"mountPath\": \"$SECRET1_MOUNT_POINT\"
  }
]
"|kubectl replace -f - --force

# 8. Wait until ready
until kubectl get pod -n $NS $POD | grep Running -c | grep 1; do sleep 1; done

# 9. Check mount
kubectl exec -it -n $NS $POD -- find $SECRET1_MOUNT_POINT

# 10. Create new secret2
kubectl create secret generic -n $NS $SECRET2 --from-literal="user=user1" --from-literal="pass=1234"

# 11. Mount secret2 into the pod
kubectl get pod $POD -n $NS -o yaml | yq "
.spec.containers[0].env=[
  {
    \"name\": \"APP_USER\",
    \"valueFrom\": {
      \"secretKeyRef\": {
        \"name\": \"$SECRET2\",
        \"key\": \"user\"
      }
    }
  },
  {
    \"name\": \"APP_PASS\",
    \"valueFrom\": {
      \"secretKeyRef\": {
        \"name\": \"$SECRET2\",
        \"key\": \"pass\"
      }
    }
  }
]
"|kubectl replace -f - --force

# 12. Wait until ready
until kubectl get pod -n $NS $POD | grep Running -c | grep 1; do sleep 1; done

# 13. Check env
kubectl exec -it -n $NS $POD -- env|grep -e USER -e PASS

