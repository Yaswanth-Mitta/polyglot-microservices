#!/bin/bash

echo "--- Deleting all Kubernetes resources from k8s/ directory recursively (Pass 1) ---"
kubectl delete -f k8s/ --recursive

echo "--- Waiting for resources to terminate... (Sleeping for 10 seconds) ---"
sleep 3

echo "--- Deleting all Kubernetes resources from k8s/ directory recursively (Pass 2) ---"
kubectl delete -f k8s/ --recursive

echo "--- Deleting Persistent Volume Claims (PVCs) ---"
kubectl delete pvc mongo-storage-notes-db-0 mongo-storage-todo-db-0 mongo-storage-user-db-0

echo "--- Deleting Persistent Volumes (PVs) ---"
kubectl delete pv notes-pv todo-pv user-pv

echo "✅ All specified Kubernetes resources have been targeted for deletion."
echo "Note: The actual data on the host machine remains. You must delete the directories manually."

