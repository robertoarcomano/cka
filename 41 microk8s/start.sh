#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"
POD_FILE="ubuntu.yaml"

# 1. Install microk8s
sudo apt update
sudo apt -y install microk8s

# 2. Start microk8s
microk8s start
microk8s status

# 3. Show usage
echo "Command to connect to microk8s:"
echo "microk8s kubectl"

# 4. Pod Test
$KUBECTL create -f $POD_FILE
