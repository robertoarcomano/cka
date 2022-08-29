#!/bin/bash

# 0. Constants
SECRET1=secret1
SECRET2=secret2
SECRET3=secret3
TLS_SECRET1=tls1
TLS_CERT=tls.crt
TLS_CSR=tls.csr
TLS_KEY=tls.key
SUBJ="/CN=tls"
DAYS=1000
ENV_FILE=env-file
FILE=file.json
POD=nginx

# 1. Create configmaps
# 1.0. Delete previous configmap
kubectl delete secret $SECRET1 $SECRET2 $SECRET3 $TLS_SECRET1

# 1.1. Create $SECRET1
kubectl create secret generic $SECRET1 --from-literal "user=roberto" --from-literal "city=Turin"

# 1.2. Create $SECRET2
kubectl create secret generic $SECRET2 --from-env-file $ENV_FILE

# 1.3. Create $SECRET3
kubectl create secret generic $SECRET3 --from-file $FILE

# 1.4.1. Create $TLS_CERT and $TLS_KEY
openssl genrsa -out $TLS_KEY 2048
openssl req -new -key $TLS_KEY -out $TLS_CSR -subj $SUBJ
openssl x509 -req -in $TLS_CSR -signkey $TLS_KEY -out $TLS_CERT -days $DAYS

# 1.4.2. Create $TLS_SECRET1
kubectl create secret tls $TLS_SECRET1 --cert $TLS_CERT --key $TLS_KEY

# 1.5. Check
kubectl get secret $SECRET1 $SECRET2 $SECRET3 $TLS_SECRET1 -o yaml

# 2. Use configmaps
# 2.0. Delete the pod
kubectl delete pod $POD

# 2.1. Add to the pod
kubectl run $POD --image nginx --dry-run=client -o yaml | yq '
.spec.volumes = [
  {"name": "vol-secret1", "secret": { "secretName": "secret1"}},
  {"name": "vol-secret2", "secret": { "secretName": "secret2"}},
  {"name": "vol-secret3", "secret": { "secretName": "secret3"}}
],
.spec.containers[0].volumeMounts = [
  {"name": "vol-secret1", "mountPath": "/tmp/secret1"},
  {"name": "vol-secret2", "mountPath": "/tmp/secret2"},
  {"name": "vol-secret3", "mountPath": "/tmp/secret3"}
],
.spec.containers[0].env = [
  {
    "name": "user",
    "valueFrom": {
      "secretKeyRef": {
        "name": "secret1",
        "key": "user"
      }
    }
  }
],
.spec.containers[0].envFrom = [
  {
    "secretRef": {
      "name": "secret2"
    }
  },
  {
    "secretRef": {
      "name": "secret3"
    }
  }
]
'|kubectl apply -f -

# 2.2. Sleep until pod is ready
echo "Waiting for the pod to become Running..."
until kubectl get pods nginx|grep Running; do sleep 1; done

# 2.3. Check for all secret from env
kubectl exec -it nginx -- env | grep -e user -e number -e country -e age

# 2.4. Check for all secret from mounted volumes
kubectl exec -it nginx -- bash -c "find /tmp/secret*"

