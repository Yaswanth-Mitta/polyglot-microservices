#!/bin/bash

set -e

DOCKER_REPO="yaswanthmitta"

mkdir -p db backend frontend

#################################
# MongoDB Deployments + Services
#################################

for svc in user todo notes; do
cat > db/${svc}-mongo-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${svc}-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${svc}-db
  template:
    metadata:
      labels:
        app: ${svc}-db
    spec:
      containers:
        - name: ${svc}-db
          image: mongo:latest
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: mongo-storage
              mountPath: /data/db
      volumes:
        - name: mongo-storage
          emptyDir: {}
EOF

cat > db/${svc}-mongo-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${svc}-db
spec:
  selector:
    app: ${svc}-db
  ports:
    - port: 27017
      targetPort: 27017
EOF
done

#################################
# Backend Apps
#################################

# user-service
cat > backend/user-deployment.yaml <<EOF
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
          image: ${DOCKER_REPO}/multiapp-user-management-go:latest
          ports:
            - containerPort: 5000
          env:
            - name: DB_HOST
              value: user-db
            - name: DB_PORT
              value: "27017"
EOF

cat > backend/user-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
    - port: 5000
      targetPort: 5000
EOF

# todo-service
cat > backend/todo-deployment.yaml <<EOF
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
          image: ${DOCKER_REPO}/multiapp-todo-app:latest
          ports:
            - containerPort: 5001
          env:
            - name: DB_HOST
              value: todo-db
            - name: DB_PORT
              value: "27017"
EOF

cat > backend/todo-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: todo-service
spec:
  selector:
    app: todo-service
  ports:
    - port: 5001
      targetPort: 5001
EOF

# notes-service
cat > backend/notes-deployment.yaml <<EOF
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
          image: ${DOCKER_REPO}/multiapp-notes-app:latest
          ports:
            - containerPort: 5002
          env:
            - name: DB_HOST
              value: notes-db
            - name: DB_PORT
              value: "27017"
EOF

cat > backend/notes-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: notes-service
spec:
  selector:
    app: notes-service
  ports:
    - port: 5002
      targetPort: 5002
EOF

# bedrock secrets
cat > backend/bedrock-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: bedrock-secrets
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: your-access-key
  AWS_SECRET_ACCESS_KEY: your-secret-key
  AWS_DEFAULT_REGION: us-east-1
EOF

# bedrock deployment
cat > backend/bedrock-deployment.yaml <<EOF
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
          image: ${DOCKER_REPO}/multiapp-bedrock-app:latest
          ports:
            - containerPort: 5005
          envFrom:
            - secretRef:
                name: bedrock-secrets
EOF

cat > backend/bedrock-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: bedrock-service
spec:
  selector:
    app: bedrock-app
  ports:
    - port: 5005
      targetPort: 5005
EOF

#################################
# Frontend
#################################

cat > frontend/nginx-configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 80;
        location / {
          root /usr/share/nginx/html;
          index index.html;
        }
        location /users/ {
          proxy_pass http://user-service:5000/;
        }
        location /todo/ {
          proxy_pass http://todo-service:5001/;
        }
        location /notes/ {
          proxy_pass http://notes-service:5002/;
        }
        location /bedrock/ {
          proxy_pass http://bedrock-service:5005/;
        }
      }
    }
EOF

cat > frontend/frontend-deployment.yaml <<EOF
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
          image: ${DOCKER_REPO}/multiapp-frontend:latest
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
EOF

cat > frontend/frontend-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
  type: NodePort
EOF

echo "✅ All Kubernetes YAMLs generated in k8s/ folder."

