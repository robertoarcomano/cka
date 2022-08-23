#!/bin/bash

# 0. Constants
KUBEADM_VERSION=1.24.4-00
KUBELET_VERSION=$KUBEADM_VERSION
CLUSTER_VERSION=1.24.4
MASTER=kube1.robertoarcomano.com
WORKER=w1.robertoarcomano.com

###################
# 1. UPGRADE MASTER
###################

# 1.1. Upgrade kubeadm
# Mark it as automatically upgradable
apt-mark unhold kubeadm
  # Check present version
  kubeadm version
  # update packages list
  apt-get update
  # Look for the chosen version
  apt-cache madison kubeadm
  # Install it
  apt install kubeadm=$KUBEADM_VERSION
  # Check present version
  kubeadm version
# Mark it as automatically not upgradable
apt-mark hold kubeadm

# 1.2. Upgrade cluster
# check for plan
kubeadm upgrade plan
# apply chosen version
kubeadm upgrade apply $CLUSTER_VERSION -y

# 1.3. Upgrade kubelet
# drain node
kubectl drain $MASTER --ignore-daemonsets
  # unmark hold kubelet
  apt-mark unhold kubelet
    # install chosen kubelet version
    apt-get install kubelet=$KUBELET_VERSION
    # check for new version
    kubectl get nodes
    # restart kubelet
    systemctl daemon-reload
    systemctl restart kubelet
  # mark hold kubelet
  apt-mark hold kubelet
# uncordon the node
kubectl uncordon $MASTER


###################
# 2. UPGRADE WORKER
###################

# 2.1. Upgrade kubeadm
# Mark it as automatically upgradable
apt-mark unhold kubeadm
  # Check present version
  kubeadm version
  # update packages list
  apt-get update
  # Look for the chosen version
  apt-cache madison kubeadm
  # Install it
  apt install kubeadm=$KUBEADM_VERSION
  # Check present version
  kubeadm version
# Mark it as not automatically upgradable
apt-mark hold kubeadm

# 2.2. Upgrade cluster configuration
kubeadm upgrade node

# 2.3. Upgrade kubelet
# drain node
kubectl drain $WORKER --ignore-daemonsets
  # unmark hold kubelet
  apt-mark unhold kubelet
    # install chosen kubelet version
    apt-get install kubelet=$KUBELET_VERSION
    # check for new version
    kubectl get nodes
    # restart kubelet
    systemctl daemon-reload
    systemctl restart kubelet
  # mark hold kubelet
  apt-mark hold kubelet
# uncordon the node
kubectl uncordon $WORKER



