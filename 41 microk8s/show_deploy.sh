#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"

# 1. Show all deploy running
$KUBECTL get deploy -A
