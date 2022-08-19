#!/bin/bash

# 0. Constants
USER=user
NUM_BITS=2048
KEY=user.key
CSR=user.csr
SUBJ="/CN=$USER/O=Group"
CAKEY=ca.key
CA=ca.crt
CERT=user.crt
DAYS=1000
ROLE=role
CLUSTER=kubernetes

# 1. Key and Certificate creation
# 1.1. Key creation
openssl genrsa -out $KEY $NUM_BITS

# 1.2. Certificate Signing Request creation
openssl req -new -key $KEY -out $CSR -subj "$SUBJ"

# 1.3. Certificate Signing
openssl x509 -req -in $CSR -CAkey "$CAKEY" -CA "$CA" -CAcreateserial -days "$DAYS" -out $CERT

# 1.3. Role creation
kubectl create role role --verb get,list --resource pod,deploy

# 1.4. Rolebinding creation
kubectl create rolebinding rolebinding --user $USER --role $ROLE

# 1.5. User creation
kubectl config set-credentials $USER --client-key $KEY --client-certificate $CERT

# 1.6. Context creation
kubectl config set-context user-kubernetes --cluster $CLUSTER --user $USER