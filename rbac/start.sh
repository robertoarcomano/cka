#!/bin/bash

# 0. Constants
NUM_BITS=2048
KEY=user.key
CSR=user.csr
SUBJ="/CN=user/O=Group"
CAKEY=ca.key
CA=ca.crt
CERT=user.crt
DAYS=1000

# 1. Key and Certificate creation
# 1.1. Key creation
openssl genrsa -out $KEY $NUM_BITS

# 1.2. Certificate Signing Request creation
openssl req -new -key $KEY -out $CSR -subj "$SUBJ"

# 1.3. Certificate Signing
openssl x509 -req -in $CSR -CAkey "$CAKEY" -CA "$CA" -CAcreateserial -days "$DAYS" -out $CERT
