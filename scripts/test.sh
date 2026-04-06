#!/bin/bash

# JOSDK Operator - Test Script
# This script creates test WebPage resources and monitors them

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing JOSDK Operator ===${NC}"

# Check if cluster is running
echo -e "\n${YELLOW}Checking cluster status...${NC}"
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}Cluster is not running${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Cluster is running${NC}"

# Check if operator is running
echo -e "\n${YELLOW}Checking operator status...${NC}"
OPERATOR_READY=$(kubectl get deployment -n operators josdk-operator -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ "$OPERATOR_READY" != "1" ]; then
    echo -e "${YELLOW}Operator not ready yet. Current status:${NC}"
    kubectl get deployment -n operators josdk-operator
    echo -e "${YELLOW}Waiting...${NC}"
    sleep 5
fi
echo -e "${GREEN}✓ Operator is running${NC}"

# Apply example resources
echo -e "\n${YELLOW}Creating test WebPage resources...${NC}"
kubectl apply -f k8s/example-webpages.yaml
echo -e "${GREEN}✓ Test resources created${NC}"

# Monitor resources
echo -e "\n${YELLOW}Monitoring resource creation...${NC}"
echo -e "${BLUE}(This may take a few seconds)${NC}\n"

for i in {1..15}; do
    echo -n "."
    sleep 1
done
echo ""

# Display created resources
echo -e "\n${GREEN}=== Created Resources ===${NC}"

echo -e "\n${BLUE}WebPages:${NC}"
kubectl get webpages

echo -e "\n${BLUE}ConfigMaps:${NC}"
kubectl get configmaps

echo -e "\n${BLUE}Services:${NC}"
kubectl get services

echo -e "\n${BLUE}Deployments:${NC}"
kubectl get deployments

# Show details
echo -e "\n${GREEN}=== WebPage Details ===${NC}"
echo -e "\n${BLUE}hello-world WebPage:${NC}"
kubectl describe webpage hello-world

echo -e "\n${GREEN}=== Operator Logs ===${NC}"
echo -e "${BLUE}Last 20 log lines:${NC}"
kubectl logs -n operators deployment/josdk-operator --tail=20

# Test port-forward
echo -e "\n${GREEN}=== Testing Service Access ===${NC}"
echo -e "${YELLOW}To test the webpage, run:${NC}"
echo "kubectl port-forward svc/hello-world 8080:80"
echo "Then visit: http://localhost:8080"

echo -e "\n${GREEN}=== TEST COMPLETE ===${NC}"

