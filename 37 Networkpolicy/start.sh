#!/bin/bash

# 0. Constants
SERVER_NAME=server
SERVER_IMAGE=nginx
CLIENT_NAME=client
CLIENT_IMAGE=busybox
CLIENT_COMMAND="while true; do wget -q http://server -O - > /dev/null && date || echo 'KO'; sleep 1; done"
NP_BLOCK_FILE=block.yaml
NP_ALLOW_FILE=allow.yaml
TIMEOUT=10

# 0. Remove network policy
kubectl delete -f $NP_BLOCK_FILE,$NP_ALLOW_FILE

# 1. Re-create server web
kubectl delete pod $SERVER_NAME --grace-period 0 --force
kubectl run $SERVER_NAME --image $SERVER_IMAGE

# 1bis. Re-create svc
kubectl delete svc $SERVER_NAME --grace-period 0 --force
kubectl expose pod $SERVER_NAME --port 80

# 2. Re-create client web
kubectl delete pod $CLIENT_NAME --grace-period 0 --force
kubectl run $CLIENT_NAME --image $CLIENT_IMAGE -- sh -c "$CLIENT_COMMAND"

# 3. Wait for client/server to settle down
until kubectl get pods $SERVER_NAME $CLIENT_NAME|grep -c Running|grep 2; do
  sleep 1;
done

# 4. Check for log for 5 seconds
echo "NO RULES"
timeout $TIMEOUT kubectl logs $CLIENT_NAME -f

# 5. Wait for 5 seconds, then apply the network policy
kubectl create -f $NP_BLOCK_FILE

# 6. Check again
echo "BLOCK RULE"
timeout $TIMEOUT kubectl logs $CLIENT_NAME -f

# 7. Wait for 5 seconds, then apply the network policy
kubectl delete -f $NP_BLOCK_FILE

# 8. Check again
echo "NO RULES"
timeout $TIMEOUT kubectl logs $CLIENT_NAME -f


