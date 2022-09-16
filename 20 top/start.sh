#!/bin/bash

# 0. Requirements and Constants
# 0.1. Install the metric server
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 0.2. Patch metrics-server: http://www.mtitek.com/tutorials/kubernetes/install-kubernetes-metrics-server.php
# kubectl patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# 1. Show node as well as pod top
kubectl top nodes
kubectl top pods