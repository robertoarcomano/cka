#!/bin/bash

# 0. Constants

# 1. List all pods from any ns, sorted in different ways
# 1.1. by creationTimestamp
echo "SHOW PODS ORDERED BY CREATIONTIMESTAMP"
kubectl get pods -A --sort-by=.metadata.creationTimestamp
echo

# 1.2. By uid
echo "SHOW PODS ORDERED BY UID"
kubectl get pods -A --sort-by=.metadata.uid
echo

# 1.3. By creationTimestamp reversed
echo "SHOW PODS ORDERED BY REVERSE CREATIONTIMESTAMP"
kubectl get pods -A --sort-by=.metadata.creationTimestamp --no-headers | tac
