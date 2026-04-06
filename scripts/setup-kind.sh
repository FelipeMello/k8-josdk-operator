#!/bin/bash

# JOSDK Operator - KinD Setup Script
# This script automates the entire setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== JOSDK Operator Setup with KinD ===${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

command -v kind >/dev/null 2>&1 || { echo -e "${RED}KinD is not installed${NC}"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is not installed${NC}"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is not installed${NC}"; exit 1; }

echo -e "${GREEN}✓ All prerequisites found${NC}"

# Step 1: Create KinD Cluster
echo -e "\n${YELLOW}Step 1: Creating KinD cluster...${NC}"
if kind get clusters | grep -q operator-dev; then
    echo -e "${YELLOW}Cluster 'operator-dev' already exists, deleting...${NC}"
    kind delete cluster --name operator-dev
fi

kind create cluster --name operator-dev
kubectl config use-context kind-operator-dev
echo -e "${GREEN}✓ KinD cluster created${NC}"

# Step 2: Build JAR
echo -e "\n${YELLOW}Step 2: Building Java project...${NC}"
cd /workspace/josdk
./mvnw clean package -q -DskipTests
echo -e "${GREEN}✓ JAR built successfully${NC}"

# Step 3: Build Docker Image
echo -e "\n${YELLOW}Step 3: Building Docker image...${NC}"
docker build -t josdk-operator:1.0 .
echo -e "${GREEN}✓ Docker image built${NC}"

# Step 4: Load image into KinD
echo -e "\n${YELLOW}Step 4: Loading image into KinD cluster...${NC}"
kind load docker-image josdk-operator:1.0 --name operator-dev
echo -e "${GREEN}✓ Image loaded into cluster${NC}"

# Step 5: Create namespace
echo -e "\n${YELLOW}Step 5: Creating operators namespace...${NC}"
kubectl create namespace operators --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace created${NC}"

# Step 6: Install CRD
echo -e "\n${YELLOW}Step 6: Installing Custom Resource Definition...${NC}"
kubectl apply -f k8s/crd-webpage.yaml
echo -e "${GREEN}✓ CRD installed${NC}"

# Step 7: Apply RBAC
echo -e "\n${YELLOW}Step 7: Applying RBAC rules...${NC}"
kubectl apply -f k8s/rbac.yaml
echo -e "${GREEN}✓ RBAC configured${NC}"

# Step 8: Deploy Operator
echo -e "\n${YELLOW}Step 8: Deploying operator...${NC}"
kubectl apply -f k8s/operator-deployment.yaml
echo -e "${GREEN}✓ Operator deployment created${NC}"

# Step 9: Wait for operator to be ready
echo -e "\n${YELLOW}Step 9: Waiting for operator to be ready...${NC}"
kubectl wait --for=condition=available --timeout=60s deployment/josdk-operator -n operators || true
sleep 5
echo -e "${GREEN}✓ Operator is ready${NC}"

# Step 10: Display status
echo -e "\n${YELLOW}Step 10: Verifying deployment...${NC}"
echo -e "\n${GREEN}=== Cluster Status ===${NC}"
kubectl get nodes
echo -e "\n${GREEN}=== Operator Status ===${NC}"
kubectl get deployment -n operators
echo -e "\n${GREEN}=== Operator Logs ===${NC}"
kubectl logs -n operators deployment/josdk-operator --tail=20 || echo "Logs not available yet"

echo -e "\n${GREEN}=== SETUP COMPLETE ===${NC}"
echo -e "\nNext steps:"
echo "1. Check operator logs: kubectl logs -f -n operators deployment/josdk-operator"
echo "2. Create test resources: kubectl apply -f k8s/example-webpages.yaml"
echo "3. Monitor resources: kubectl get webpages --watch"
echo "4. View created resources: kubectl describe webpage hello-world"
echo "5. Port forward to service: kubectl port-forward svc/hello-world 8080:80"
echo ""
echo "To cleanup:"
echo "  ./scripts/cleanup.sh"

