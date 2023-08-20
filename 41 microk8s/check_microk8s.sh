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
fi

