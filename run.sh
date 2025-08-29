#!/bin/bash
set -e

echo "🚀 Deploying database..."
kubectl apply -f k8s/db/

echo "🚀 Deploying backend..."
kubectl apply -f k8s/backend/

echo "🚀 Deploying frontend..."
kubectl apply -f k8s/frontend/

echo "✅ All services deployed successfully!"

