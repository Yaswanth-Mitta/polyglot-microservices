#!/bin/bash

# Define the directory where the deployments are located
DEPLOYMENTS_DIR="k8s/deployments"

echo "Adding Liveness and Readiness Probes to deployment manifests in $DEPLOYMENTS_DIR..."

# Deployment for bedrock-app
cat > "$DEPLOYMENTS_DIR/bedrock-app.yaml" << EOF
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
          livenessProbe:
            httpGet:
              path: /healthz
              port: 5005
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /healthz
              port: 5005
            initialDelaySeconds: 5
            periodSeconds: 10
EOF

# Deployment for notes-service
cat > "$DEPLOYMENTS_DIR/notes-service.yaml" << EOF
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
          livenessProbe:
            httpGet:
              path: /healthz
              port: 5002
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /healthz
              port: 5002
            initialDelaySeconds: 5
            periodSeconds: 10
EOF

# Deployment for todo-service
cat > "$DEPLOYMENTS_DIR/todo-service.yaml" << EOF
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
          livenessProbe:
            httpGet:
              path: /healthz
              port: 5001
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /healthz
              port: 5001
            initialDelaySeconds: 5
            periodSeconds: 10
EOF

# Deployment for user-service
cat > "$DEPLOYMENTS_DIR/user-service.yaml" << EOF
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
          livenessProbe:
            httpGet:
              path: /healthz
              port: 5000
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /healthz
              port: 5000
            initialDelaySeconds: 5
            periodSeconds: 10
EOF

# Deployment for frontend-deployment
cat > "$DEPLOYMENTS_DIR/frontend-deployment.yaml" << EOF
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
          livenessProbe:
            httpGet:
              path: /healthz
              port: 80
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /healthz
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
EOF

echo "✅ All deployment manifests in the '$DEPLOYMENTS_DIR' folder have been updated with probes."
echo "You can now re-apply them using: kubectl apply -f $DEPLOYMENTS_DIR/"
