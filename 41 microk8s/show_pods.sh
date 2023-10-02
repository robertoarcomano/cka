#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"

# 1. Show all pods running
$KUBECTL get pods -A
