#!/bin/bash

# 0. Constants
KUBECTL="microk8s kubectl"

# 1. Create service
$KUBECTL expose pod ubuntu --port=80 --target-port=8080 --name=web-service
