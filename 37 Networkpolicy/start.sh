#!/bin/bash

# 0. Constants
WORKER1=w1
CERT_CLIENT=/var/lib/kubelet/pki/kubelet-client-current.pem
CERT_SERVER=/var/lib/kubelet/pki/kubelet.crt
ISSUER=Issuer
EXTENDED_KEY_USAGE="Extended Key Usage"

# 1. Get info for client
echo "CLIENT:"
ssh root@$WORKER1 openssl x509 -text -in $CERT_CLIENT -noout|grep -A1 -e "$ISSUER" -e "$EXTENDED_KEY_USAGE"
echo

# 2. Get info for server
echo "SERVER:"
ssh root@$WORKER1 openssl x509 -text -in $CERT_SERVER -noout|grep -A1 -e "$ISSUER" -e "$EXTENDED_KEY_USAGE"
