# Azure Blob Storage Deployment Plan

## Overview
Deploy a Zone-Redundant Storage (ZRS) account in Azure for general blob storage purposes. The deployment must support dynamic naming to allow multi-region deployments without naming collisions.

## Requirements
- **Region**: Default `eastus2`, but parameterized.
- **SKU**: `Standard_ZRS` (Zone Redundant Storage).
- **Kind**: `StorageV2` (General Purpose v2).
- **Access**: Public endpoint enabled.
- **Naming**: Dynamic, using a base name + unique string suffix based on the resource group to ensure global uniqueness.

## Architecture

### Resources
1.  **Resource Group**: Container for the resources. Default name: `rg-blob-storage-<region>`.
2.  **Storage Account**: The main storage resource.
    -   Name format: `stblob${uniqueString(resourceGroup().id)}` (or similar pattern to ensure length < 24 chars and uniqueness).
    -   Location: Same as resource group.
    -   Sku: `Standard_ZRS`.
    -   Properties:
        -   `supportsHttpsTrafficOnly`: true
        -   `allowBlobPublicAccess`: false (Best practice, unless specifically required for anonymous access. User said "public endpoint is fine", which usually means network access, not anonymous auth. I will default to secure default but allow public network access).
        -   `minimumTlsVersion`: 'TLS1_2'

### File Component Structure
-   `infra/main.bicep`: Entry point. Creates Resource Group (optional scope) or deploys to subscription scope and creates RG.
    -   *Correction*: To match the pattern in `hello-world`, `main.bicep` will be `targetScope = 'subscription'` and create the Resource Group, then call the module.
-   `infra/storage.bicep`: Module to create the storage account.

## Step-by-Step Implementation Plan

1.  **Create Infrastructure Directory**:
    -   Create `workloads/blob-storage/infra`.

2.  **Develop `infra/storage.bicep`**:
    -   Parameters: `location`, `storageAccountName` (or base name).
    -   Resource: `Microsoft.Storage/storageAccounts`.
    -   Outputs: Storage Account Name, ID, Primary Endpoint.

3.  **Develop `infra/main.bicep`**:
    -   `targetScope = 'subscription'`.
    -   Parameters: `location` (default 'eastus2'), `rgName` (default dynamic based on location).
    -   Logic:
        -   Create Resource Group.
        -   Generate unique storage name: `st${uniqueString(subscription().id, rgName)}` (ensure it's < 24 chars, maybe trim).
        -   Call `storage.bicep` module.

4.  **Create Deployment Script**:
    -   `deploy.sh` for easy execution.

5.  **Documentation**:
    -   `README.md` explaining how to deploy and parameters.

## Validation
-   Validate Bicep files using `az bicep build`.
-   Verify SKUs match requirements (`Standard_ZRS`).
-   Verify naming is dynamic.
