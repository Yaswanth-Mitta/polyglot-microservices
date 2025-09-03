#!/bin/bash

# Define the root directory for the new structure
K8S_ROOT="k8s"

# --- Clean up previous deployments folder and create new ones ---
echo "Cleaning up old 'deployments' folder and creating new 'hpa' and updated 'deployments' folders..."
rm -rf "$K8S_ROOT/deployments"
mkdir -p "$K8S_ROOT/deployments"
mkdir -p "$K8S_ROOT/hpa"

# --- Create HPA manifests for each deployment ---

# HPA for bedrock-app
cat > "$K8S_ROOT/hpa/bedrock-app-hpa.yaml" << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bedrock-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: bedrock-app
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
EOF

# HPA for notes-service
cat > "$K8S_ROOT/hpa/notes-service-hpa.yaml" << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: notes-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: notes-service
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
EOF

# HPA for todo-service
cat > "$K8S_ROOT/hpa/todo-service-hpa.yaml" << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: todo-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: todo-service
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
EOF

# HPA for user-service
cat > "$K8S_ROOT/hpa/user-service-hpa.yaml" << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: user-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: user-service
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
EOF

# HPA for frontend
cat > "$K8S_ROOT/hpa/frontend-hpa.yaml" << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
EOF

# --- Update Deployment files with resource limits ---

cat > "$K8S_ROOT/deployments/bedrock-app.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bedrock-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bedrock-app
  template:
    metadata:
      labels:
        app: bedrock-app
    spec:
      containers:
        - name: bedrock-app
          image: yaswanthmitta/multiapp-bedrock-app:latest
          ports:
            - containerPort: 5005
          envFrom:
            - secretRef:
                name: bedrock-secrets
          resources:
            limits:
              memory: "100Mi"
            requests:
              memory: "50Mi"
EOF

cat > "$K8S_ROOT/deployments/notes-service.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notes-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: notes-service
  template:
    metadata:
      labels:
        app: notes-service
    spec:
      containers:
        - name: notes-service
          image: yaswanthmitta/multiapp-notes-app:latest
          ports:
            - containerPort: 5002
          env:
            - name: DB_HOST
              value: notes-db
            - name: DB_PORT
              value: "27017"
          resources:
            limits:
              memory: "100Mi"
            requests:
              memory: "50Mi"
EOF

cat > "$K8S_ROOT/deployments/todo-service.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo-service
  template:
    metadata:
      labels:
        app: todo-service
    spec:
      containers:
        - name: todo-service
          image: yaswanthmitta/multiapp-todo-app:latest
          ports:
            - containerPort: 5001
          env:
            - name: DB_HOST
              value: todo-db
            - name: DB_PORT
              value: "27017"
          resources:
            limits:
              memory: "100Mi"
            requests:
              memory: "50Mi"
EOF

cat > "$K8S_ROOT/deployments/user-service.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
        - name: user-service
          image: yaswanthmitta/multiapp-user-management-go:latest
          ports:
            - containerPort: 5000
          env:
            - name: DB_HOST
              value: user-db
            - name: DB_PORT
              value: "27017"
          resources:
            limits:
              memory: "100Mi"
            requests:
              memory: "50Mi"
EOF

cat > "$K8S_ROOT/deployments/frontend-deployment.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: yaswanthmitta/multiapp-frontend:latest
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
          resources:
            limits:
              memory: "100Mi"
            requests:
              memory: "50Mi"
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
EOF

echo "✅ HPA manifests have been created and deployments updated with resource limits in the '$K8S_ROOT' directory."
echo "Here is the new folder structure:"
tree "$K8S_ROOT"

