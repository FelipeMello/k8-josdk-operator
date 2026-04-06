#!/bin/bash

# JOSDK Operator - Cleanup Script
# This script removes all operator resources from KinD cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Cleaning up JOSDK Operator ===${NC}"

# Delete WebPage resources
echo -e "\n${YELLOW}Deleting WebPage resources...${NC}"
kubectl delete webpages --all -n default --ignore-not-found=true
echo -e "${GREEN}✓ WebPage resources deleted${NC}"

# Delete Operator Deployment
echo -e "\n${YELLOW}Deleting operator deployment...${NC}"
kubectl delete -f k8s/operator-deployment.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Operator deployment deleted${NC}"

# Delete RBAC
echo -e "\n${YELLOW}Deleting RBAC resources...${NC}"
kubectl delete -f k8s/rbac.yaml --ignore-not-found=true
echo -e "${GREEN}✓ RBAC deleted${NC}"

# Delete CRD
echo -e "\n${YELLOW}Deleting CRD...${NC}"
kubectl delete -f k8s/crd-webpage.yaml --ignore-not-found=true
echo -e "${GREEN}✓ CRD deleted${NC}"

# Delete namespace
echo -e "\n${YELLOW}Deleting operators namespace...${NC}"
kubectl delete namespace operators --ignore-not-found=true
echo -e "${GREEN}✓ Namespace deleted${NC}"

# Delete KinD cluster
echo -e "\n${YELLOW}Deleting KinD cluster...${NC}"
kind delete cluster --name operator-dev
echo -e "${GREEN}✓ KinD cluster deleted${NC}"

echo -e "\n${GREEN}=== CLEANUP COMPLETE ===${NC}"

