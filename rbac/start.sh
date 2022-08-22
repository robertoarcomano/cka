#!/bin/bash

# 0. Constants
USER=user1
NUM_BITS=2048
KEY=$USER.key
CSR=$USER.csr
SUBJ="/CN=$USER/O=Group"
CAKEY=ca.key
CA=ca.crt
CERT=$USER.crt
DAYS=1000
ROLE=role1
ROLEBINDING=rolebinding1
CLUSTER=kubernetes
CONTEXT=$USER"-"$CLUSTER

# 1. Key and Certificate creation
# 1.1. Key creation
openssl genrsa -out $KEY $NUM_BITS

# 1.2. Certificate Signing Request creation
openssl req -new -key $KEY -out $CSR -subj "$SUBJ"

# 1.3. Certificate Signing
openssl x509 -req -in $CSR -CAkey "$CAKEY" -CA "$CA" -CAcreateserial -days "$DAYS" -out $CERT

# 1.3. Role creation
kubectl delete role $ROLE
kubectl create role $ROLE --verb get,list --resource pod,deploy

# 1.4. Rolebinding creation
kubectl delete rolebinding $ROLEBINDING
kubectl create rolebinding $ROLEBINDING --user $USER --role $ROLE

# 1.5. User creation
kubectl config set-credentials $USER --client-key $KEY --client-certificate $CERT

# 1.6. Context creation
kubectl config set-context $CONTEXT --cluster $CLUSTER --user $USER

# 1.7. Documentation
echo ""
echo "You can now use: kubectl config use-context $CONTEXT"
