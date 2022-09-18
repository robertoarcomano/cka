#!/bin/bash

# 0. Constants
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')
CERT_PATH=/etc/kubernetes/pki/apiserver.crt
NOT_AFTER="Not After : "

# 1. check api-server cert using openssl
ssh root@$MASTER openssl x509 -text -in $CERT_PATH -noout|grep "$NOT_AFTER"|awk -F"$NOT_AFTER" '{print $NF}'

# 2. check api-server cert using kubeadm
ssh root@$MASTER kubeadm certs check-expiration |grep apiserver|grep -v "-"|cut -c 28-49

# 3. Renew command
ssh root@$MASTER kubeadm certs renew apiserver
