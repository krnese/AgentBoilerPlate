# Hello World Workload

This workload deploys a simple "Hello World" Node.js application to Azure App Service using Azure Bicep for infrastructure-as-code.

## Overview

The application is a basic Node.js HTTP server that responds with "Hello World" on the root path. It is hosted on an Azure Web App (Linux) running on a Free (F1) App Service Plan.

## Architecture

The solution consists of the following Azure resources:

- **Azure App Service Plan**: Linux, Free Tier (F1).
- **Azure App Service (Web App)**: Node.js 20 LTS runtime.

## Prerequisites

Before deploying, ensuring you have the following tools installed:

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- `node` and `npm` (for local development)
- `zip` (used by the deployment script)
- `jq` (used by the deployment script)

## Project Structure

- `src/`: Application source code (`server.js`).
- `infra/`: Infrastructure definitions (Bicep).
  - `app.bicep`: Defines the Web App and App Service Plan.
  - `main.bicep`: Subscription-level deployment (optional usage).
- `deploy.sh`: Automated deployment script.
- `package.json`: Node.js project definition.

## Local Development

To run the application locally:

1. Install dependencies (if any):
   ```bash
   npm install
   ```

2. Start the server:
   ```bash
   npm start
   ```

3. Open [http://localhost:8080](http://localhost:8080) in your browser.

## Deployment

A deployment script `deploy.sh` is provided to automate the provisioning and code deployment process.

1. Make the script executable (if needed):
   ```bash
   chmod +x deploy.sh
   ```

2. Log in to Azure:
   ```bash
   az login
   ```

3. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

The script performs the following steps:
1. Creates a Resource Group (default: `rg-hello-world-weu`).
2. Deploys the infrastructure using `infra/app.bicep`.
3. Packages the application code into `app.zip`.
4. Deploys the package to the Azure Web App.

After successful deployment, the script outputs the **Web App URL**.

## Clean Up

To remove the deployed resources, delete the resource group:

```bash
az group delete --name rg-hello-world-weu --yes --no-wait
```
