---
name: azure-openai-deployment
description: Deploy Azure OpenAI service with GPT models and networking configuration
agent: Planner
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'azure-resource-graph/*', 'microsoftdocs/mcp/*', 'agent', 'todo']
---

# Azure OpenAI Service Deployment

## Request

I need an Azure OpenAI service deployed in **East US** for **production** use with proper security but using public endpoints.

## Requirements

1. **Azure OpenAI Service**: Create the cognitive services account
2. **Model Deployments**: Deploy the following models:
   - GPT-4o (latest version)
   - GPT-4o-mini
   - text-embedding-ada-002
3. **Networking**: Publid endpoint enabled.
4. **Security**: 
   - Enable managed identity

## Technical Details

- Use Standard (S0) pricing tier
- Configure rate limits and quotas appropriately
- Set up content filtering policies
- Enable Azure AD authentication

## Preferences

- Resource naming: `<type>-openai-prod-eastus`
- Use **system-assigned managed identity**
- Include sample Python/Node.js code to call the API
- Document the endpoint URLs and authentication methods

## What I Expect

- Fully deployed Azure OpenAI service with models
- Private networking configured (VNet + Private Endpoint)
- Key Vault with secrets properly stored
- Sample application code that demonstrates:
  - Chat completion with GPT-4o
  - Embeddings generation
  - Proper authentication with managed identity
- Documentation on how to test the deployment
- Cost estimate for running this configuration
- Security best practices implemented

## Nice to Have

- Log Analytics workspace for centralized logging, and diagnostics settings enabled on the resource(s)
- Azure Monitor alerts for quota usage
