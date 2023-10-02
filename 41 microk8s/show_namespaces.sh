#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"

# 1. Show all ns
$KUBECTL get ns
