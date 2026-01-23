# Blob Storage Workload

This workload deploys a **Zone-Redundant Storage (ZRS)** account in Azure using Bicep.

## Features

- **SKU**: Standard_ZRS (Zone-Redundant)
- **Region**: Default `eastus2`
- **Naming**: Dynamic and globally unique naming logic.
- **Security**: Public internet access enabled (network), but anonymous blob access disabled. HTTPS only.

## Deployment

### Prerequisites
- Azure CLI installed and logged in (`az login`).
- `jq` installed (optional, for script output parsing).

### Using the Script
Run the helper script to deploy the resources:

```bash
chmod +x deploy.sh
./deploy.sh
```

### Manual Deployment
You can also deploy directly using Azure CLI:

```bash
az deployment sub create \
  --location eastus2 \
  --template-file infra/main.bicep
```

## Resources Created

- **Resource Group**: `rg-blob-storage-eastus2` (default)
- **Storage Account**: `stblob<unique-string>`
- **Blob Container**: `data` (Private access)

## Infrastructure Files

- `infra/main.bicep`: Subscription-level deployment that creates the Resource Group.
- `infra/storage.bicep`: Module that creates the Storage Account.
