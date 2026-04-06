# JOSDK Operator - Docker & KinD Deployment Guide

## Overview
This guide shows how to run your Java Operator SDK (JOSDK) operator in a Docker container using KinD for local Kubernetes development.

## Architecture
```
Docker Development Environment
    ↓
Build JOSDK Operator JAR
    ↓
Build Docker Image
    ↓
KinD Cluster (runs in Docker)
    ↓
Deploy Operator Pod
    ↓
Create WebPage Resources
    ↓
Operator creates ConfigMaps, Services, Deployments
```

## Prerequisites
Ensure you're in the Docker development environment with:
- Docker installed and running
- KinD installed: `kind version`
- kubectl installed: `kubectl version`
- Java 25+: `java -version`
- Maven 3.9+: `./mvnw -version`

## Quick Start (Automated)

### Option 1: Run Setup Script (Recommended)

```bash
cd /workspace/josdk

# Make scripts executable
chmod +x scripts/*.sh

# Run automated setup
./scripts/setup-kind.sh
```

This script will:
1. ✅ Create a KinD cluster
2. ✅ Build the Java project
3. ✅ Build Docker image
4. ✅ Load image into KinD
5. ✅ Create namespace
6. ✅ Install CRD
7. ✅ Apply RBAC
8. ✅ Deploy operator
9. ✅ Verify everything is working

## Manual Setup (Step-by-Step)

### Step 1: Build the Java Project

```bash
cd /workspace/josdk

# Clean and build
./mvnw clean package -DskipTests

# Expected: Shows 37MB JAR file
ls -lh target/josdkoperator-0.0.1-SNAPSHOT.jar
```

**Output:**
```
-rw-r--r-- 1 root root 37M Apr  6 10:49 target/josdkoperator-0.0.1-SNAPSHOT.jar
```

### Step 2: Build Docker Image

```bash
# Build the Docker image
docker build -t josdk-operator:1.0 .

# Verify image is built
docker images | grep josdk-operator
```

**Expected output:**
```
josdk-operator   1.0      abc123def456   1.5 seconds ago   500MB
```

### Step 3: Create KinD Cluster

```bash
# Delete existing cluster (if any)
kind delete cluster --name operator-dev 2>/dev/null || true

# Create new cluster
kind create cluster --name operator-dev

# Set kubectl context
kubectl config use-context kind-operator-dev

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

**Expected output:**
```
NAME                          STATUS   ROLES           AGE
operator-dev-control-plane    Ready    control-plane   30s
```

### Step 4: Load Docker Image into KinD

```bash
# Load your image into the KinD cluster
kind load docker-image josdk-operator:1.0 --name operator-dev

# Verify (inside KinD)
docker exec operator-dev-control-plane ctr images ls | grep josdk
```

### Step 5: Create Namespace

```bash
kubectl create namespace operators
kubectl get namespace operators
```

### Step 6: Install Custom Resource Definition (CRD)

```bash
# Install WebPage CRD
kubectl apply -f k8s/crd-webpage.yaml

# Verify CRD is installed
kubectl get crd webpages.example.com
kubectl explain webpages
```

**Expected output:**
```
NAME                      CREATED AT
webpages.example.com      2025-04-06T10:30:00Z
```

### Step 7: Apply RBAC (Role-Based Access Control)

```bash
# Apply RBAC rules
kubectl apply -f k8s/rbac.yaml

# Verify ServiceAccount
kubectl get serviceaccount -n operators
kubectl get clusterrole | grep josdk
```

**Expected output:**
```
NAME               SECRETS   AGE
josdk-operator     0         5s
```

### Step 8: Deploy the Operator

```bash
# Deploy operator
kubectl apply -f k8s/operator-deployment.yaml

# Verify deployment exists
kubectl get deployment -n operators

# Wait for it to be ready (usually 30-60 seconds)
kubectl wait --for=condition=available --timeout=60s deployment/josdk-operator -n operators

# Check pod status
kubectl get pods -n operators
```

**Expected output:**
```
NAME                              READY   STATUS    RESTARTS   AGE
josdk-operator-5f7d9c8b4c-xyz12   1/1     Running   0          15s
```

### Step 9: Monitor Operator Logs

```bash
# Stream operator logs
kubectl logs -f -n operators deployment/josdk-operator

# Alternative: view last 50 lines
kubectl logs -n operators deployment/josdk-operator --tail=50
```

**Expected output:**
```
2025-04-06 10:30:00 INFO: Starting JOSDK Operator with Spring Boot
2025-04-06 10:30:02 INFO: Kubernetes client connected
```

### Step 10: Create Test Resources

```bash
# Apply example WebPage resources
kubectl apply -f k8s/example-webpages.yaml

# Monitor creation
kubectl get webpages --watch

# In another terminal, check created resources
kubectl get configmap
kubectl get service
kubectl get deployment
```

## Testing the Operator

### Test 1: Verify WebPage Creation

```bash
# Create a simple webpage
cat <<EOF | kubectl apply -f -
apiVersion: example.com/v1
kind: WebPage
metadata:
  name: test-page
spec:
  title: "Test Page"
  html: "<h1>Hello from Kubernetes Operator!</h1>"
EOF

# Check if it was created
kubectl get webpage test-page
kubectl describe webpage test-page
```

### Test 2: Verify Generated Resources

```bash
# Check ConfigMap was created
kubectl get configmap test-page
kubectl describe configmap test-page

# Check Service was created
kubectl get service test-page
kubectl describe service test-page

# Check Deployment was created
kubectl get deployment test-page
kubectl describe deployment test-page
```

### Test 3: Access the Webpage

```bash
# Port-forward to the service
kubectl port-forward svc/test-page 8080:80 &

# In another terminal
sleep 2
curl http://localhost:8080

# Kill port-forward
pkill -f "port-forward"
```

## Troubleshooting

### Issue: Operator pod is stuck in pending

```bash
# Check pod status
kubectl describe pod -n operators -l app=josdk-operator

# Check node resources
kubectl describe nodes

# Check logs
kubectl logs -n operators deployment/josdk-operator
```

### Issue: Image pull error

```bash
# Verify image is loaded in KinD
kind load docker-image josdk-operator:1.0 --name operator-dev

# Check available images in cluster
docker exec operator-dev-control-plane ctr images ls
```

### Issue: CRD not recognized

```bash
# Verify CRD is installed
kubectl get crds | grep webpages

# If missing, apply it
kubectl apply -f k8s/crd-webpage.yaml

# Check CRD details
kubectl describe crd webpages.example.com
```

### Issue: RBAC permission denied

```bash
# Check ServiceAccount permissions
kubectl auth can-i create webpages --as=system:serviceaccount:operators:josdk-operator

# Verify ClusterRoleBinding
kubectl get clusterrolebinding | grep josdk

# Check ClusterRole rules
kubectl describe clusterrole josdk-operator
```

### Issue: Resources not being created by operator

```bash
# Check operator logs for errors
kubectl logs -f -n operators deployment/josdk-operator | grep -i error

# Check WebPage status
kubectl describe webpage test-page

# Verify operator is running
kubectl get pods -n operators
```

## Useful Commands

```bash
# Cluster Management
kind create cluster --name operator-dev
kind delete cluster --name operator-dev
kubectl config use-context kind-operator-dev
kubectl cluster-info

# Build & Deploy
cd /workspace/josdk
./mvnw clean package
docker build -t josdk-operator:1.0 .
kind load docker-image josdk-operator:1.0 --name operator-dev

# Deployment
kubectl apply -f k8s/crd-webpage.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/operator-deployment.yaml

# Monitoring
kubectl get pods -n operators
kubectl logs -f -n operators deployment/josdk-operator
kubectl get webpages
kubectl describe webpage <name>

# Resource Inspection
kubectl get all -n operators
kubectl get configmap
kubectl get service
kubectl get deployment

# Cleanup
./scripts/cleanup.sh
```

## Running Automated Tests

```bash
# Make test script executable
chmod +x scripts/test.sh

# Run tests
./scripts/test.sh
```

This script will:
1. ✅ Check cluster status
2. ✅ Verify operator is running
3. ✅ Create test resources
4. ✅ Monitor resource creation
5. ✅ Display operator logs
6. ✅ Show access instructions

## Cleanup

### Option 1: Use Cleanup Script
```bash
./scripts/cleanup.sh
```

### Option 2: Manual Cleanup
```bash
# Delete WebPage resources
kubectl delete webpages --all

# Delete operator
kubectl delete -f k8s/operator-deployment.yaml

# Delete RBAC
kubectl delete -f k8s/rbac.yaml

# Delete CRD
kubectl delete -f k8s/crd-webpage.yaml

# Delete namespace
kubectl delete namespace operators

# Delete cluster
kind delete cluster --name operator-dev
```

## Development Workflow

### 1. Make Changes to Operator Code
```bash
# Edit WebPageReconciler.java or other files
vim src/main/java/com/k8/josdkoperator/WebPageReconciler.java
```

### 2. Rebuild
```bash
./mvnw clean package
docker build -t josdk-operator:1.0 .
kind load docker-image josdk-operator:1.0 --name operator-dev
```

### 3. Update Operator Pod
```bash
# Kill the old pod (Kubernetes will restart it with new image)
kubectl delete pod -n operators -l app=josdk-operator

# Monitor new pod startup
kubectl logs -f -n operators deployment/josdk-operator
```

### 4. Test Changes
```bash
./scripts/test.sh
```

## Next Steps

1. **Extend the Operator**: Add custom reconciliation logic
2. **Add Validation**: Use Kubernetes validation rules
3. **Add Metrics**: Integrate Prometheus monitoring
4. **Error Handling**: Improve error handling and retries
5. **Unit Tests**: Add comprehensive unit and integration tests
6. **CI/CD**: Set up GitHub Actions for automated testing

## References

- [KinD Documentation](https://kind.sigs.k8s.io/)
- [JOSDK Documentation](https://javaoperatorsdk.io/)
- [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Custom Resources](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/)
- [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

---

**You now have a complete Java Kubernetes operator running in Docker with KinD!**

