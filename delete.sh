#!/bin/bash
set -e

echo "🗑️ Deleting frontend..."
kubectl delete -f k8s/frontend/

echo "🗑️ Deleting backend..."
kubectl delete -f k8s/backend/

echo "🗑️ Deleting database..."
kubectl delete -f k8s/db/

echo "✅ All services deleted!"

