#!/bin/bash

# 0. Constants
CRONJOB=cronjob.yaml

# 1. Re-create the cronjob
kubectl replace -f $CRONJOB --force

# 2. Show the cronjob
kubectl get cronjob