#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"

# 1. Check microk8s
microk8s status

# 2. Check DNS is running
DNS=$(microk8s status -a dns|grep enabled|wc -l)
if [ "$DNS" -eq 1 ]; then
  echo "DNS is installed and running"
else
  echo "DNS is missing"
  echo "Attempt to restart DNS..."
  microk8s enable dns
fi

# 3. Check Prometheus
PROMETHEUS=$(microk8s status -a prometheus|grep enabled|wc -l)
if [ "$PROMETHEUS" -eq 1 ]; then
  echo "PROMETHEUS is installed and running"
else
  echo "PROMETHEUS is missing"
  echo "Attempt to restart PROMETHEUS..."
  microk8s enable prometheus
fi
