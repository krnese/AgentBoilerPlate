---
name: static-web-app-functions
description: Deploy a Static Web App with Azure Functions backend and blob storage
agent: Planner
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'azure-resource-graph/*', 'microsoftdocs/mcp/*', 'agent', 'todo']
---

# Static Web App with Azure Functions Backend

## Request

I need a serverless web application in **West Europe** with the following:

1. **Frontend**: Azure Static Web App hosting a simple React app
2. **Backend**: Azure Functions (Node.js) with HTTP triggers
3. **Storage**: Azure Storage Account for storing user uploads (blob storage)
4. **Environment**: Production

## Requirements

- **Authentication**: Enable Azure AD authentication on the Static Web App
- **API Integration**: Static Web App integrated with Functions backend
- **CORS**: Properly configured for frontend-backend communication
- **Storage**: Private blob container with SAS token access from Functions
- **Monitoring**: Application Insights for both Static Web App and Functions
- **Cost**: Use consumption/free tiers where possible
- **Security**: Follow Azure security best practices (managed identities, private endpoints where applicable)

## Preferences

- Use **TypeScript** for Functions
- Use **React** for frontend (you can create a simple starter)
- Use **managed identity** for Functions to access Storage (no connection strings)
- Deploy everything in the **same resource group**
- Use a naming convention like: `<resource-type>-webapp-prod-<region>`

## What I Expect

- Complete infrastructure deployed and working
- A simple React frontend that can call the Functions API
- Functions API that can upload/list files in blob storage
- Full documentation on how to test it
- All code and infrastructure ready to use
