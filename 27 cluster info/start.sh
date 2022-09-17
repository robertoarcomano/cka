#!/bin/bash

# 0. Constants
MASTERS=$(kubectl get nodes --no-headers|grep control-plane -c)
WORKERS=$(kubectl get nodes --no-headers|grep -v control-plane -c)
SERVICE_CIDR=$(ssh kube1 grep service-cluster -r /etc/kubernetes/|head -1|awk -F"=" '{print $NF}')
CNI_PLUGIN=$(ssh kube1 "find /etc/cni -type f|xargs cat"|yq '.name')
CNI_CONFIG_FILE=$(ssh kube1 "find /etc/cni -type f")
SUFFIX_STATIC_PODS=$(kubectl get pods |grep `kubectl get nodes|grep w1|awk '{print $1}'`|awk '{print $1}'|awk -F"-" '{print $NF}')

#1 Show info
echo "Masters: $MASTERS"
echo "Workers: $WORKERS"
echo "Service CIDR: $SERVICE_CIDR"
echo "CNI Plugin: $CNI_PLUGIN, CNI config file: $CNI_CONFIG_FILE"
echo "Suffix static pods: $SUFFIX_STATIC_PODS"

