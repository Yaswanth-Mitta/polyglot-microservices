#!/bin/bash

# Define the root directory for the new structure
K8S_ROOT="k8s"

# --- Clean up previous run and create the main directories ---
echo "Cleaning up existing '$K8S_ROOT' directory..."
rm -rf "$K8S_ROOT"

echo "Creating new folder structure..."
mkdir -p "$K8S_ROOT/deployments"
mkdir -p "$K8S_ROOT/services"
mkdir -p "$K8S_ROOT/statefulsets"
mkdir -p "$K8S_ROOT/persistentvolumes"
mkdir -p "$K8S_ROOT/persistentvolumeclaims"
mkdir -p "$K8S_ROOT/configmaps"
mkdir -p "$K8S_ROOT/secrets"

# --- Populate the files with hardcoded YAML content ---

## Deployments
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
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
EOF

# ---

## StatefulSets
cat > "$K8S_ROOT/statefulsets/notes-db-statefulset.yaml" << EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: notes-db
spec:
  serviceName: "notes-db"
  replicas: 1
  selector:
    matchLabels:
      app: notes-db
  template:
    metadata:
      labels:
        app: notes-db
    spec:
      containers:
        - name: notes-db
          image: mongo:latest
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: mongo-storage
              mountPath: /data/db
  volumeClaimTemplates:
    - metadata:
        name: mongo-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
EOF

cat > "$K8S_ROOT/statefulsets/todo-db-statefulset.yaml" << EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: todo-db
spec:
  serviceName: "todo-db"
  replicas: 1
  selector:
    matchLabels:
      app: todo-db
  template:
    metadata:
      labels:
        app: todo-db
    spec:
      containers:
        - name: todo-db
          image: mongo:latest
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: mongo-storage
              mountPath: /data/db
  volumeClaimTemplates:
    - metadata:
        name: mongo-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
EOF

cat > "$K8S_ROOT/statefulsets/user-db-statefulset.yaml" << EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: user-db
spec:
  serviceName: "user-db"
  replicas: 1
  selector:
    matchLabels:
      app: user-db
  template:
    metadata:
      labels:
        app: user-db
    spec:
      containers:
        - name: user-db
          image: mongo:latest
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: mongo-storage
              mountPath: /data/db
  volumeClaimTemplates:
    - metadata:
        name: mongo-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
EOF

# ---

## Services
cat > "$K8S_ROOT/services/bedrock-service.yaml" << EOF
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

cat > "$K8S_ROOT/services/notes-service.yaml" << EOF
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

cat > "$K8S_ROOT/services/todo-service.yaml" << EOF
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

cat > "$K8S_ROOT/services/user-service.yaml" << EOF
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

cat > "$K8S_ROOT/services/frontend-service.yaml" << EOF
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

cat > "$K8S_ROOT/services/notes-db-service.yaml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: notes-db
spec:
  clusterIP: None
  selector:
    app: notes-db
  ports:
    - port: 27017
      targetPort: 27017
EOF

cat > "$K8S_ROOT/services/todo-db-service.yaml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: todo-db
spec:
  clusterIP: None
  selector:
    app: todo-db
  ports:
    - port: 27017
      targetPort: 27017
EOF

cat > "$K8S_ROOT/services/user-db-service.yaml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: user-db
spec:
  clusterIP: None
  selector:
    app: user-db
  ports:
    - port: 27017
      targetPort: 27017
EOF

# ---

## Persistent Volumes
cat > "$K8S_ROOT/persistentvolumes/notes-pv.yaml" << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: notes-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/home/ubuntu/data/notes"
EOF

cat > "$K8S_ROOT/persistentvolumes/todo-pv.yaml" << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: todo-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/home/ubuntu/data/todo"
EOF

cat > "$K8S_ROOT/persistentvolumes/user-pv.yaml" << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/home/ubuntu/data/user"
EOF

# ---

## ConfigMaps
cat > "$K8S_ROOT/configmaps/nginx-config.yaml" << EOF
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

        # Serve static frontend files
        location / {
          root /usr/share/nginx/html;
          index index.html;
          try_files \$uri \$uri/ /index.html;
        }

        # API reverse proxy routes
        location /api/users/ {
          proxy_pass http://user-service:5000/;
        }

        location /api/todo/ {
          proxy_pass http://todo-service:5001/;
        }

        location /api/notes/ {
          proxy_pass http://notes-service:5002/;
        }

        location /api/bedrock/ {
          proxy_pass http://bedrock-service:5005/;
        }
      }
    }
EOF

# ---

## Secrets
cat > "$K8S_ROOT/secrets/bedrock-secrets.yaml" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: bedrock-secrets
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: \${AWS_ACCESS_KEY_ID}
  AWS_SECRET_ACCESS_KEY: \${AWS_SECRET_ACCESS_KEY}
  AWS_DEFAULT_REGION: \${AWS_DEFAULT_REGION}
EOF

# ---

echo "✅ Kubernetes manifests have been organized and created in the '$K8S_ROOT' directory."
echo "Here is the new folder structure:"
tree "$K8S_ROOT"
