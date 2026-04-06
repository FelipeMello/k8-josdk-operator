# 🚀 JOSDK Operator - Quick Start Guide

## TL;DR - Run Everything in 3 Minutes

```bash
cd /workspace/josdk
chmod +x scripts/*.sh
./scripts/setup-kind.sh
```

**That's it!** Your operator will be running in KinD.

---

## What Happens When You Run Setup

The `./scripts/setup-kind.sh` script automatically:

1. ✅ **Builds** the Java operator JAR (37 MB)
2. ✅ **Creates** a KinD Kubernetes cluster
3. ✅ **Builds** Docker image (`josdk-operator:1.0`)
4. ✅ **Loads** image into KinD cluster
5. ✅ **Installs** WebPage CRD
6. ✅ **Configures** RBAC permissions
7. ✅ **Deploys** the operator pod
8. ✅ **Verifies** everything is working

**Total time: ~2-3 minutes**

---

## Test Your Operator

### Create Test WebPages

```bash
kubectl apply -f k8s/example-webpages.yaml
```

### Watch Resources Being Created

```bash
# Terminal 1: Watch WebPages
kubectl get webpages --watch

# Terminal 2: Watch Services
kubectl get services --watch

# Terminal 3: Watch ConfigMaps
kubectl get configmaps --watch
```

### Check Operator Logs

```bash
kubectl logs -f -n operators deployment/josdk-operator
```

### Access a Webpage

```bash
# Port-forward to access the webpage
kubectl port-forward svc/hello-world 8080:80

# In another terminal
curl http://localhost:8080
```

---

## Manual Setup (If You Want to Do It Yourself)

### 1. Build the Project

```bash
cd /workspace/josdk
./mvnw clean package -DskipTests
```

### 2. Build Docker Image

```bash
docker build -t josdk-operator:1.0 .
```

### 3. Create KinD Cluster

```bash
kind create cluster --name operator-dev
kubectl config use-context kind-operator-dev
```

### 4. Load Image into KinD

```bash
kind load docker-image josdk-operator:1.0 --name operator-dev
```

### 5. Deploy to Kubernetes

```bash
# Create namespace
kubectl create namespace operators

# Install CRD
kubectl apply -f k8s/crd-webpage.yaml

# Apply RBAC
kubectl apply -f k8s/rbac.yaml

# Deploy operator
kubectl apply -f k8s/operator-deployment.yaml

# Wait for ready
kubectl wait --for=condition=available --timeout=60s deployment/josdk-operator -n operators
```

---

## Project Structure

```
/workspace/josdk/
├── 📦 BUILD
│   ├── pom.xml                        # Maven config
│   ├── mvnw                           # Maven wrapper
│   └── target/josdkoperator-*.jar     # Built JAR
├── 🐳 DOCKER
│   └── Dockerfile                     # Container definition
├── ⚙️ KUBERNETES
│   └── k8s/
│       ├── crd-webpage.yaml           # Custom Resource Definition
│       ├── rbac.yaml                  # Permissions
│       ├── operator-deployment.yaml   # Operator deployment
│       └── example-webpages.yaml      # Test resources
├── 🔧 SCRIPTS
│   ├── setup-kind.sh                  # Automated setup
│   ├── test.sh                        # Automated testing
│   └── cleanup.sh                     # Automated cleanup
└── 📝 CODE
    └── src/main/java/com/k8/josdkoperator/
        ├── JosdkOperatorApplication.java  # Main entry point
        ├── WebPageReconciler.java         # Reconciliation logic
        └── customresource/                # CRD definitions
            ├── WebPage.java
            ├── WebPageSpec.java
            └── WebPageStatus.java
```

---

## Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Java | 25.0.2 | Runtime |
| Maven | 3.9.14 | Build tool |
| Spring Boot | 4.0.5 | Application framework |
| JOSDK | 5.3.2 | Operator framework |
| Kubernetes | Latest | Target platform |
| KinD | Latest | Local K8s cluster |
| Docker | Latest | Container runtime |

---

## How the Operator Works

### 1. WebPage Resource Created
```yaml
apiVersion: example.com/v1
kind: WebPage
metadata:
  name: my-site
spec:
  html: "<h1>Hello World!</h1>"
  title: "My Site"
```

### 2. Operator Detects It
Your `WebPageReconciler` watches for new WebPage resources.

### 3. Operator Creates Resources
Automatically creates:
- **ConfigMap** with HTML content
- **Service** to expose the webpage
- **Deployment** running NGINX

### 4. Resources Are Linked
All created resources are owned by the WebPage (automatic cleanup).

---

## Development Workflow

### Make Changes

```bash
# Edit reconciliation logic
vim src/main/java/com/k8/josdkoperator/WebPageReconciler.java
```

### Rebuild & Redeploy

```bash
# Rebuild
./mvnw clean package
docker build -t josdk-operator:1.0 .

# Load into KinD
kind load docker-image josdk-operator:1.0 --name operator-dev

# Restart operator pod
kubectl delete pod -n operators -l app=josdk-operator
```

### Test Changes

```bash
./scripts/test.sh
```

---

## Useful Commands

### Build & Run
```bash
./mvnw clean compile      # Just compile
./mvnw clean package      # Build JAR
docker build -t josdk-operator:1.0 .  # Build image
```

### KinD Management
```bash
kind create cluster --name operator-dev
kind delete cluster --name operator-dev
kubectl config use-context kind-operator-dev
```

### Kubernetes Operations
```bash
kubectl get pods -n operators
kubectl logs -f -n operators deployment/josdk-operator
kubectl get webpages
kubectl describe webpage <name>
```

### Testing
```bash
kubectl apply -f k8s/example-webpages.yaml
kubectl port-forward svc/hello-world 8080:80
curl http://localhost:8080
```

### Cleanup
```bash
./scripts/cleanup.sh
```

---

## Troubleshooting

### Operator Pod Won't Start
```bash
# Check pod status
kubectl describe pod -n operators -l app=josdk-operator

# Check logs
kubectl logs -n operators deployment/josdk-operator
```

### Resources Not Being Created
```bash
# Check operator logs for errors
kubectl logs -f -n operators deployment/josdk-operator | grep -i error

# Verify RBAC permissions
kubectl auth can-i create webpages --as=system:serviceaccount:operators:josdk-operator
```

### CRD Not Recognized
```bash
# Reinstall CRD
kubectl apply -f k8s/crd-webpage.yaml

# Check CRD status
kubectl get crd webpages.example.com
```

### Image Pull Issues
```bash
# Reload image into KinD
kind load docker-image josdk-operator:1.0 --name operator-dev

# Check available images
docker exec operator-dev-control-plane ctr images ls
```

---

## Next Steps

1. **Run the setup**: `./scripts/setup-kind.sh`
2. **Test the operator**: `./scripts/test.sh`
3. **Customize logic**: Edit `WebPageReconciler.java`
4. **Add features**: Extend the WebPage CRD
5. **Deploy to production**: Use real Kubernetes cluster

---

## Documentation

- **[DOCKER_KIND_GUIDE.md](DOCKER_KIND_GUIDE.md)** - Complete deployment guide
- **[SPRING_BOOT_GUIDE.md](SPRING_BOOT_GUIDE.md)** - Configuration and customization
- **[CHANGES.md](CHANGES.md)** - What was changed in the project

---

## Need Help?

1. Check the troubleshooting section above
2. Review operator logs: `kubectl logs -f -n operators deployment/josdk-operator`
3. Check pod status: `kubectl describe pod -n operators -l app=josdk-operator`
4. Verify RBAC: `kubectl get clusterrolebinding josdk-operator`

---

**Ready to start? Run: `./scripts/setup-kind.sh`** 🚀
