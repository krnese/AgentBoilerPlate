# Azure Web App "Hello Johan" Deployment Plan

## Overview
This plan outlines the steps to build, validate, and deploy a simple "Hello Johan" Node.js application to an Azure Web App hosted in `swedencentral`.

## Architecture
- **Region**: `swedencentral` (Sweden Central)
- **Stack**: Node.js (Version 20 LTS recommended)
- **OS**: Linux
- **Compute**: App Service Plan (SKU: F1 Free for dev/test)
- **Resource Group**: `rg-hello-johan-swc`

## Steps

### Phase 1: Application Development
1.  Initialize a new Node.js project.
2.  Create `server.js` with a simple HTTP server responding "Hello Johan".
3.  Create `package.json` with start scripts.
4.  Local validation.

### Phase 2: Infrastructure as Code (Bicep)
1.  Create `infra/main.bicep`.
2.  Define `Microsoft.Web/serverfarms` (App Service Plan).
3.  Define `Microsoft.Web/sites` (Web App).
4.  Ensure `serverfarms` location is set to `swedencentral`.

### Phase 3: Deployment Automation
1.  Create `deploy.sh` script.
2.  Script actions:
    - Create Resource Group if it doesn't exist.
    - Deploy Bicep template to provision infrastructure.
    - Zip up application content.
    - Deploy application using `az webapp deployment source config-zip`.

### Phase 4: Validation
1.  Run the deployment script.
2.  Query the allocated URL.
3.  Verify response is "Hello Johan".

## Handoff
- Developer Agent: Implement Phases 1-4.
