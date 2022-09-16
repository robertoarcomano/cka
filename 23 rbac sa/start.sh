#!/bin/bash

# 0. Constants
MASTER=$(kubectl get nodes --no-headers|grep control-plane|awk '{print $1}')


# 1. Temporary kill the scheduler

