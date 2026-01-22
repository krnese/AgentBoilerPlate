@description('The name of the web app that you wish to create.')
param appName string = 'app-hello-world-swc-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = 'swedencentral'

var appServicePlanName = 'plan-hello-world-swc'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
    }
  }
}

output siteUrl string = 'https://${webApp.properties.defaultHostName}'
