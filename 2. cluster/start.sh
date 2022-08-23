#!/bin/bash

# 0. Constants
POD_NETWORK=10.244.0.0/16
API_SERVER_IP=192.168.10.156
API_SERVER_PORT=6443
TOKEN="n8yyyq.j9cr4a4zacsj1r0w"
TOKEN_HASH="sha256:d8cb883f468ec3b81fb04386f41fd1e48368fe36eca7f94c5bb2f7932d648a9e"

# 1. Initialize Kubernetes cluster
kubeadm init --pod-network-cidr "$POD_NETWORK" --apiserver-advertise-address "$API_SERVER_IP"

# 2. Install pod network addon
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# 3. Join the cluster
kubeadm join "$API_SERVER_IP":"$API_SERVER_PORT" --token "$TOKEN" --discovery-token-ca-cert-hash "$TOKEN_HASH"

