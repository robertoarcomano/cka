#!/bin/bash

# 0. Constants
POD_NETWORK=10.244.0.0/16
API_SERVER_IP=192.168.10.156
API_SERVER_PORT=6443
TOKEN="m1wz9i.5jaoea1keiy9ny4o"
TOKEN_HASH="sha256:1976e913c32bef595cc52020a16fd9887c8e0009d480169690d6964eaa8a90a2"

# 1. Initialize Kubernetes cluster on master node
kubeadm init --pod-network-cidr "$POD_NETWORK" --apiserver-advertise-address "$API_SERVER_IP"

# 2. Copy configuration file.json on master node
mkdir ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config

# 3. Install pod network addon on master node
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# 4. Join the cluster on each worker node
echo kubeadm join "$API_SERVER_IP":"$API_SERVER_PORT" --token "$TOKEN" --discovery-token-ca-cert-hash "$TOKEN_HASH"
