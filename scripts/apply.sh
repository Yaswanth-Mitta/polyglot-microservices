#!/bin/bash

# This script applies all Kubernetes manifest files in the 'k8s/' directory
# and its subdirectories.

# Set the base directory for Kubernetes manifests
K8S_DIR="k8s/"

# Check if the directory exists
if [ ! -d "$K8S_DIR" ]; then
  echo "Error: The directory '$K8S_DIR' does not exist."
  echo "Please create it and place your Kubernetes manifest files inside."
  exit 1
fi

echo "Applying Kubernetes manifests from '$K8S_DIR' recursively..."

# Run the kubectl command
kubectl apply -f "$K8S_DIR" -R

echo "Successfully applied all manifests."
