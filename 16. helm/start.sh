#!/bin/bash

# 0. Constants
REPO_SRC=https://charts.bitnami.com/bitnami
REPO_NAME=bitnami
CHART=drupal
STORAGE_CLASS=nfs-client

# 1. Add lamp repository
helm repo remove $REPO_NAME
helm repo add $REPO_NAME $REPO_SRC

# 2. Install lamp
helm uninstall $CHART
helm install $CHART bitnami/$CHART --set global.storageClass=$STORAGE_CLASS --set mariadb.primary.persistence.storageClass=$STORAGE_CLASS

# 3. Autentication data
echo Username: user
echo Password: $(kubectl get secret --namespace default drupal -o jsonpath="{.data.drupal-password}" | base64 -d)

# 3. Connection link
export SERVICE_IP=$(kubectl get svc --namespace default drupal -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "Drupal URL: http://$SERVICE_IP/"
