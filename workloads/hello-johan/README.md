# Hello Johan Workload

This project describes a simple Node.js application deployed to Azure Web Apps. It responds with a friendly "Hello Johan" message.

## Project Structure

```
workloads/hello-johan/
├── deploy.sh           # Deployment automation script
├── infra/              # Infrastructure as Code (Bicep)
│   ├── main.bicep      # Subscription-level entry point
│   ├── app.bicep       # App Service resources definitions (invoked by main)
│   └── main.json       # (Optional) Parameter parameters or build artifacts
├── src/                # Application source code
│   ├── server.js       # Main Node.js server
│   └── package.json    # Application metadata and scripts
└── app.zip             # (Generated) Deployment artifact
```

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in.
- [jq](https://jqlang.github.io/jq/) installed (for parsing JSON output in the deploy script).
- [zip](https://linux.die.net/man/1/zip) utility installed.

## Usage

### Running Locally

1. Navigate to the `src` directory:
   ```bash
   cd src
   ```

2. Start the server:
   ```bash
   npm start
   ```
   *Or directly:* `node server.js`

3. Open your browser or curl:
   ```bash
   curl http://localhost:8080
   ```

## Deployment

The project includes a `deploy.sh` script that automates the provisioning of Azure resources and the deployment of the application code.

### Deployment Steps

1. Make sure you are at the root of the workload (`workloads/hello-johan`).

2. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

### What `deploy.sh` does:

1. **Infrastructure Provisioning**: 
   - Uses `infra/main.bicep` to update/create the Resource Group (`rg-hello-johan-swc`) and the App Service resources in `swedencentral`.
   - Retrieves the Web App name and URL from the deployment outputs.

2. **Artifact Packaging**:
   - Zips the contents of the `src` directory into `app.zip`.

3. **Code Deployment**:
   - Uses `az webapp deployment source config-zip` to push the package to the created Azure Web App.

4. **Validation**:
   - Waits briefly for a restart and curls the endpoint to verify the deployment.

## Infrastructure

- **Scope**: Subscription Level (creates Resource Group).
- **Resource Group**: `rg-hello-johan-swc`
- **Region**: Sweden Central
- **Resources**: Azure App Service Plan and Web App (defined in `infra/`).
