#!/bin/bash
set -e

# Change directory to the script's location
cd "$(dirname "$0")"

LOCATION="westeurope"
RG_NAME="rg-hello-world-weu"
APP_NAME_SUFFIX="agent-$RANDOM"

echo "Starting deployment..."

# Check login
if ! az account show > /dev/null 2>&1; then
    echo "Please login using 'az login'"
    exit 1
fi

# Step 1: Create Resource Group
echo "Creating Resource Group '$RG_NAME'..."
az group create --name $RG_NAME --location $LOCATION --output none

# Step 2: Deploy App Resources
echo "Deploying Infrastructure..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group $RG_NAME \
  --template-file infra/app.bicep \
  --parameters location=$LOCATION appName=$APP_NAME_SUFFIX \
  --output json)

APP_URL=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.appUrl.value')
WEB_APP_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.webAppName.value')

echo "Infrastructure Ready."
echo "  Web App: $WEB_APP_NAME"
echo "  URL:     $APP_URL"

# Step 3: Package
echo "Packaging application..."
rm -f app.zip
if ! zip -r app.zip package.json src/ > /dev/null; then
    echo "Error: zip command failed"
    exit 1
fi

# Step 4: Deploy Code
echo "Deploying code..."
# Using 'az webapp deploy' which is newer than 'config-zip'
az webapp deploy \
  --resource-group $RG_NAME \
  --name $WEB_APP_NAME \
  --src-path app.zip

echo "✅ Deployment complete."
echo "Validating..."
sleep 5
curl "$APP_URL"
echo ""
