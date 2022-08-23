#!/bin/bash

# 0. Constants
CA_CERT=/etc/kubernetes/pki/etcd/ca.crt
CERT=/etc/kubernetes/pki/etcd/server.crt
KEY=/etc/kubernetes/pki/etcd/server.key
SNAPSHOT_FILE=/tmp/snapshot.db
TO_RESTORE_DATA_DIR="/var/lib/etcd_restored"
ORIGINAL_DATA_DIR="\/var\/lib\/etcd"
RESTORED_DATA_DIR="\/var\/lib\/etcd_restored"

ETCD_MANIFEST_PATH=/etc/kubernetes/manifests/etcd.yaml

# 1. Backup
ETCDCTL_API=3 etcdctl \
  --cacert $CA_CERT \
  --cert $CERT \
  --key $KEY \
  snapshot save $SNAPSHOT_FILE

# 2. Restore
etcdctl snapshot restore --data-dir $TO_RESTORE_DATA_DIR $SNAPSHOT_FILE

# 3. Apply the restored version
sed -ri "\"s/path: $ORIGINAL_DATA_DIR/path: $RESTORED_DATA_DIR/\"" $ETCD_MANIFEST_PATH

# 4. Just wait for etcd to reload the new configuration
