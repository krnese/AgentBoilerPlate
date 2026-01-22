# Azure Web App "Hello World" Deployment Plan

## Overview
This plan outlines the steps to build, validate, and deploy a "Hello-World" Node.js application to an Azure Web App hosted in `westeurope`.

## Architecture
- **Region**: `westeurope` (West Europe)
- **Stack**: Node.js (Version 20 LTS)
- **OS**: Linux
- **Compute**: App Service Plan (SKU: F1 Free or B1 Basic)
- **Resource Group**: `rg-hello-world-weu`

## Steps

### Phase 1: Application Development
1.  Initialize a new Node.js project.
2.  Create `server.js` responding with "Hello World".
3.  Create `package.json` with start scripts.
4.  Local validation.

### Phase 2: Infrastructure as Code (Bicep)
1.  Create `infra/main.bicep` (Subscription Scope for RG creation) and `infra/app.bicep` (Module for resources).
2.  Define `Microsoft.Web/serverfarms`.
3.  Define `Microsoft.Web/sites`.
    - **Configuration**: Ensure `linuxFxVersion` is `NODE|20-lts`.
    - **Security**: Enable `httpsOnly`.

### Phase 3: Deployment Automation
1.  Create `deploy.sh` script.
2.  Script actions:
    - Login check.
    - Deploy Bicep template.
    - Zip application.
    - Deploy via `az webapp deploy` or `config-zip`.

### Phase 4: Validation
1.  Run the deployment script.
2.  Query the allocated URL.
3.  Verify response is "Hello World".

## Handoff
- Developer Agent: Implement Phases 1-4.
