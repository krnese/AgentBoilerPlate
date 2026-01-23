#!/bin/bash
set -e

# Change directory to the script's location
cd "$(dirname "$0")"

LOCATION="eastus2"

echo "Starting deployment..."

# Check login
if ! az account show > /dev/null 2>&1; then
    echo "Please login using 'az login'"
    exit 1
fi

echo "Deploying to Subscription (creating Resource Group and Storage Account)..."

# Deploy main.bicep at subscription scope
DEPLOYMENT_OUTPUT=$(az deployment sub create \
  --location $LOCATION \
  --template-file infra/main.bicep \
  --parameters location=$LOCATION \
  --output json)

RG_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.resourceGroupName.value')
STORAGE_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.storageAccountName.value')
BLOB_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.blobEndpoint.value')

echo "Deployment Complete."
echo "  Resource Group:  $RG_NAME"
echo "  Storage Account: $STORAGE_NAME"
echo "  Blob Endpoint:   $BLOB_ENDPOINT"

# Get storage account key
echo ""
echo "Retrieving storage account keys..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $STORAGE_NAME --query "[0].value" -o tsv)

if [ -n "$ACCOUNT_KEY" ]; then
    echo "  Primary Key:       $ACCOUNT_KEY"
    echo "  Connection String: DefaultEndpointsProtocol=https;AccountName=$STORAGE_NAME;AccountKey=$ACCOUNT_KEY;EndpointSuffix=core.windows.net"
else
    echo "  Failed to retrieve storage account key."
fi
