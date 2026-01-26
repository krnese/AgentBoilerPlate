#!/bin/bash
set -e

# Variables
RG_NAME="rg-hello-johan-swc"
LOCATION="swedencentral"

echo "Deploying Infrastructure..."
# Deploy Bicep (Subscription Scope)
# Capture the outputs
DEPLOYMENT_OUTPUT=$(az deployment sub create \
  --location $LOCATION \
  --template-file infra/main.bicep \
  --output json)

# Parse relevant outputs
WEB_APP_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.webAppName.value')
WEB_APP_URL=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.webAppUrl.value')

echo "Infrastructure Deployed."
echo "Web App Name: $WEB_APP_NAME"
echo "Web App URL: $WEB_APP_URL"

echo "Packaging Application..."
cd src
zip -r ../app.zip ./*
cd ..

echo "Deploying Application..."
az webapp deployment source config-zip \
  --resource-group $RG_NAME \
  --name $WEB_APP_NAME \
  --src app.zip

echo "Deployment Complete!"
echo "Validating..."
sleep 10 # Give it a moment to restart
curl -s $WEB_APP_URL
echo ""
