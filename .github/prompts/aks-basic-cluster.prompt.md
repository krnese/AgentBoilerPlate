---
name: aks-basic-cluster
description: Deploy a basic AKS cluster with NGINX ingress and sample app
agent: Planner
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'azure-resource-graph/*', 'microsoftdocs/mcp/*', 'agent', 'todo']
---

# Azure Kubernetes Service (AKS) Basic Cluster

## Request

I need a basic AKS cluster in **UK South** for a **development** environment. Keep it simple and cost-effective.

## Requirements

1. **AKS Cluster**: Single node pool with 2 nodes
2. **Networking**: Azure CNI networking
3. **Node Size**: Use the cheapest VM SKU suitable for development
4. **Ingress**: NGINX ingress controller
5. **Sample App**: Deploy a simple nginx pod with a service and ingress rule
6. **Monitoring**: Container Insights enabled

## Preferences

- Use **system-assigned managed identity**
- Enable **Azure Policy** for Kubernetes
- Use **Standard** load balancer (not Basic)
- Resource naming: `aks-dev-uksouth`, `rg-aks-dev-uksouth`
- Include kubectl commands to verify the deployment

## What I Expect

- Working AKS cluster
- Sample application accessible via ingress
- YAML manifests for the sample deployment
- Commands to test the ingress endpoint
- Documentation on how to connect with kubectl
- Cost estimate for running this cluster

## Nice to Have

- Helm chart for the sample app
- Azure Key Vault integration (optional)
- Automatic upgrades configured
