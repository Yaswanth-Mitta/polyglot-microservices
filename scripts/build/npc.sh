#!/bin/bash

# Define the root directory for the new structure
K8S_ROOT="k8s"
POLICY_DIR="$K8S_ROOT/network-policies"

# --- Clean up previous run and create the main directory ---
echo "Creating new folder for Network Policies..."
rm -rf "$POLICY_DIR"
mkdir -p "$POLICY_DIR"

# --- Create Network Policy manifests ---

# 1. Default Deny All Ingress Policy
cat > "$POLICY_DIR/00-default-deny-ingress.yaml" << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
echo "Created default deny ingress policy."

# 2. Allow Ingress from Frontend to Backends
cat > "$POLICY_DIR/01-allow-frontend-ingress-to-backends.yaml" << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-ingress-to-backends
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: bedrock-app
    - podSelector:
        matchLabels:
          app: notes-service
    - podSelector:
        matchLabels:
          app: todo-service
    - podSelector:
        matchLabels:
          app: user-service
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-ingress-from-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: notes-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 5002
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-todo-ingress-from-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: todo-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 5001
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-user-ingress-from-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: user-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 5000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-bedrock-ingress-from-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: bedrock-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 5005
EOF
echo "Created policies for ingress traffic from frontend to backends."

# 3. Allow Ingress from Backends to Databases
cat > "$POLICY_DIR/02-allow-db-ingress-from-backends.yaml" << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-notes-db-ingress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: notes-db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: notes-service
    ports:
    - protocol: TCP
      port: 27017
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-todo-db-ingress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: todo-db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: todo-service
    ports:
    - protocol: TCP
      port: 27017
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-user-db-ingress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: user-db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: user-service
    ports:
    - protocol: TCP
      port: 27017
EOF
echo "Created policies for ingress traffic from backends to their respective databases."

echo "✅ Network Policy manifests have been created in the '$POLICY_DIR' directory."
echo "Here is the new folder structure:"
tree "$K8S_ROOT"
