#!/bin/bash

# 0. Constants
REPO_SRC=https://lead4good.github.io/lamp-helm-repository
REPO_NAME=lamp
CHART=k8s-lamp
STORAGE_CLASS=nfs-client

# 1. Add lamp repository
helm repo remove $REPO_NAME
helm repo add $REPO_NAME $REPO_SRC

# 2. Install lamp
helm uninstall $CHART
helm install $CHART $REPO_NAME/$REPO_NAME --set persistence.storageClass=$STORAGE_CLASS




