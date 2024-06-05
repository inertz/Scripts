#!/bin/bash

# Check if a pod name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <pod-name>"
  exit 1
fi

# Assign the provided pod name to a variable
POD_NAME=$1

# Run the command with the provided pod name
sudo microk8s kubectl logs "$POD_NAME" -n openstack
