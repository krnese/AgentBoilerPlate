// Main Bicep template for Kristian's Wine Cellar
// Deploys at subscription scope to create resource group and Static Web App

targetScope = 'subscription'

@description('The Azure region for the resources')
param location string = 'swedencentral'

@description('The name of the resource group')
param resourceGroupName string = 'rg-kristians-wine-cellar-swc'

@description('The name of the Static Web App')
param staticWebAppName string = 'swa-kristians-wine-cellar'

@description('The SKU for the Static Web App')
param sku string = 'Free'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy Static Web App via module
module staticWebApp 'staticwebapp.bicep' = {
  name: 'staticWebAppDeployment'
  scope: rg
  params: {
    location: location
    staticWebAppName: staticWebAppName
    sku: sku
  }
}

// Outputs
output resourceGroupName string = rg.name
output staticWebAppName string = staticWebApp.outputs.staticWebAppName
output staticWebAppUrl string = staticWebApp.outputs.staticWebAppUrl
output staticWebAppId string = staticWebApp.outputs.staticWebAppId
