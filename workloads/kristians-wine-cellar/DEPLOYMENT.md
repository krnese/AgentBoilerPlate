# Deployment Commands for Kristian's Wine Cellar

This file documents the exact Azure CLI commands used to deploy the application.
These commands should be executed by someone with Azure credentials.

## Step 1: Validate Bicep Templates

```bash
# Navigate to infrastructure directory
cd workloads/kristians-wine-cellar/infra

# Build and validate Bicep templates
az bicep build --file main.bicep

# What-If deployment (preview changes)
az deployment sub what-if \
  --name kristians-wine-cellar-deployment \
  --location swedencentral \
  --template-file main.bicep \
  --parameters resourceGroupName=rg-kristians-wine-cellar-swc \
               location=swedencentral \
               staticWebAppName=swa-kristians-wine-cellar \
               sku=Free
```

## Step 2: Deploy Infrastructure

```bash
# Deploy at subscription scope
az deployment sub create \
  --name kristians-wine-cellar-deployment \
  --location swedencentral \
  --template-file main.bicep \
  --parameters resourceGroupName=rg-kristians-wine-cellar-swc \
               location=swedencentral \
               staticWebAppName=swa-kristians-wine-cellar \
               sku=Free

# Wait for deployment to complete
az deployment sub wait \
  --name kristians-wine-cellar-deployment \
  --created
```

## Step 3: Retrieve Deployment Information

```bash
# Get the resource group name
RESOURCE_GROUP=$(az deployment sub show \
  --name kristians-wine-cellar-deployment \
  --query properties.outputs.resourceGroupName.value -o tsv)

echo "Resource Group: $RESOURCE_GROUP"

# Get the Static Web App name
STATIC_WEB_APP_NAME=$(az deployment sub show \
  --name kristians-wine-cellar-deployment \
  --query properties.outputs.staticWebAppName.value -o tsv)

echo "Static Web App Name: $STATIC_WEB_APP_NAME"

# Get the Static Web App URL
APP_URL=$(az deployment sub show \
  --name kristians-wine-cellar-deployment \
  --query properties.outputs.staticWebAppUrl.value -o tsv)

echo "Application URL: $APP_URL"

# Get the Static Web App ID
STATIC_WEB_APP_ID=$(az deployment sub show \
  --name kristians-wine-cellar-deployment \
  --query properties.outputs.staticWebAppId.value -o tsv)

echo "Static Web App ID: $STATIC_WEB_APP_ID"

# Get the deployment token
DEPLOYMENT_TOKEN=$(az staticwebapp secrets list \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query properties.apiKey -o tsv)

echo "Deployment Token: $DEPLOYMENT_TOKEN (keep this secret!)"
```

## Step 4: Deploy Static Content

### Option A: Using Static Web Apps CLI (Recommended)

```bash
# Install SWA CLI if not already installed
npm install -g @azure/static-web-apps-cli

# Navigate to source directory
cd ../src

# Deploy using the deployment token
swa deploy . \
  --deployment-token "$DEPLOYMENT_TOKEN" \
  --app-location . \
  --output-location . \
  --env production
```

### Option B: Using Azure CLI with ZIP deployment

```bash
# Create a zip file of the source
cd ../src
zip -r ../wine-cellar.zip . -x "*.git*" "*.DS_Store"
cd ..

# Upload the zip file (requires additional configuration)
# Note: Static Web Apps typically uses GitHub Actions or SWA CLI
# This method may require setting up a storage account for staging
```

### Option C: Manual upload via Azure Portal

If CLI deployment doesn't work:
1. Navigate to Azure Portal
2. Find the Static Web App: swa-kristians-wine-cellar
3. Go to "Deployment" section
4. Use the deployment token to configure deployment
5. Upload files manually or connect to GitHub

## Step 5: Verify Deployment

```bash
# Check deployment status
az staticwebapp show \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP

# Test the endpoint
curl -I $APP_URL

# Open in browser
echo "Open this URL in your browser: $APP_URL"

# Or use Azure CLI to open
az staticwebapp browse \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP
```

## Step 6: Test Application Functionality

Once deployed, test the following:

1. **Homepage loads**: Navigate to $APP_URL
2. **Wine catalog displays**: Check if 12 wines are visible
3. **Filters work**: Test type, country, price filters
4. **Search works**: Search for "Bordeaux" or "Champagne"
5. **Sorting works**: Sort by price, rating, name
6. **Wine details**: Click on a wine to see details
7. **Cart operations**:
   - Add wines to cart
   - Update quantities
   - Remove items
   - View cart total
8. **Responsive design**: Test on mobile, tablet, desktop
9. **Browser console**: Check for no errors

## Step 7: Monitor and Troubleshoot

```bash
# View Static Web App logs
az monitor activity-log list \
  --resource-id $STATIC_WEB_APP_ID \
  --max-events 20

# Check resource group resources
az resource list \
  --resource-group $RESOURCE_GROUP \
  --output table

# Get Static Web App configuration
az staticwebapp show \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --output json
```

## Cleanup (if needed)

```bash
# Delete the entire resource group and all resources
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait

# Or delete just the deployment
az deployment sub delete \
  --name kristians-wine-cellar-deployment
```

## Common Issues and Solutions

### Issue: Deployment token not working
**Solution**: Regenerate the token:
```bash
az staticwebapp secrets reset \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP
```

### Issue: Files not updating
**Solution**: Clear the cache and redeploy:
```bash
az staticwebapp environment clear \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP
```

### Issue: 404 errors
**Solution**: Check the app location configuration and ensure index.html is in the root.

### Issue: CORS errors
**Solution**: Static Web Apps should handle this automatically, but verify the configuration.

## Notes

- The Free tier of Static Web Apps includes:
  - 100 GB bandwidth per month
  - 0.5 GB storage
  - Custom domains support
  - Automatic HTTPS
  - Global distribution via CDN

- Deployment typically takes 2-5 minutes
- DNS propagation may take up to 48 hours for custom domains
- The deployment token should be kept secure and not committed to version control
