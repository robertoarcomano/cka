#!/bin/bash

# 0. Constants
JOB=job.yaml

# 1. Re-create a job
kubectl replace -f $JOB --force

# 2. Show job
kubectl get job
