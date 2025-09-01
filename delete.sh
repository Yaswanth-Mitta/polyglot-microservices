#!/bin/bash
set -e

echo "🛑 Step 1: Deleting StatefulSets..."
kubectl delete sts --all --ignore-not-found=true

echo "🛑 Step 2: Deleting Deployments..."
kubectl delete deploy --all --ignore-not-found=true

echo "🛑 Step 3: Deleting Services (but keeping default 'kubernetes' service)..."
for svc in $(kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep -v "^kubernetes$"); do
  echo "   Deleting service: $svc"
  kubectl delete svc "$svc" --ignore-not-found=true
done

echo "🗑️ Step 4: Deleting PVCs..."
kubectl delete pvc --all --ignore-not-found=true

echo "🗑️ Step 5: Deleting PVs..."
kubectl delete pv --all --ignore-not-found=true

echo "🛑 Step 6: Deleting ConfigMaps..."
kubectl delete configmap --all --ignore-not-found=true

echo "🛑 Step 7: Deleting Secrets..."
kubectl delete secret --all --ignore-not-found=true

echo "🛑 Step 8: Deleting any remaining Pods..."
kubectl delete pods --all --ignore-not-found=true

echo "✅ Cleanup complete!"

