#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"

# 1. Check microk8s
microk8s status

# 2. Check all
$KUBECTL get all -A

