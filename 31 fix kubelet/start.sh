#!/bin/bash

# 0. Constants
WORKER1=w1

# 1. Look for kubelet process
ssh $WORKER1 << EOF
  systemctl status kubelet
  ps xal|grep -i kubelet
  ls -al /etc/systemd/system/kubelet.service.d
  cat /etc/systemd/system/kubelet.service.d/*
  systemctl status kubelet
  systemctl daemon-reload
  systemctl start kubelet
EOF
