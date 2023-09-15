#!/bin/bash
# 1. Check microk8s
microk8s status

# 2. Check K8S is running
K8S=$(microk8s status|grep microk8s is running|wc -l)
if [ "$K8S" -eq 1 ]; then
  echo "microk8s is installed and running"
else
  echo "K8s is not running"
  echo "Attempt to start it..."
  microk8s start
fi
