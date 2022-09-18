#!/bin/bash

# 0. Constants
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')
JOIN_COMMAND=$(ssh -n root@$MASTER kubeadm token create --print-join-command)

# 1. check cluster status
kubectl get nodes
echo

# 2. check worker kubelet as well as kubeadm version
kubectl get nodes --no-headers|grep -v control-plane|awk '{print $1}'|while read WORKER; do
  echo "***********************"
  echo $WORKER
  echo "***********************"

  # 2.1. Check versions
  ssh -n root@"$WORKER" "kubeadm version 2>/dev/null; kubelet --version 2>/dev/null; kubectl version 2>/dev/null"

  # 2.2. Loop for applications
  echo "kubeadm
kubelet
kubectl
"| while read PKG; do
    # 2.3. Update application
    ssh -n root@$WORKER "apt-mark unhold $PKG; apt-get install $PKG=1.24.4-00 -y; apt-mark hold $PKG"
  done

  # 2.4. Upgrade node
  ssh -n root@"$WORKER" "kubeadm upgrade node"

  # 2.5. Restart kubelet
  ssh -n root@"$WORKER" "systemctl daemon-reload"
  ssh -n root@"$WORKER" "systemctl restart kubelet"

  # 2.6. Join the cluster
  ssh -n root@"$WORKER" $JOIN_COMMAND
  echo
done
