targetScope = 'subscription'

param location string = 'swedencentral'
param resourceGroupName string = 'rg-hello-johan-swc'
param appName string = 'app-hello-johan-${uniqueString(subscription().id)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module appResources 'app.bicep' = {
  name: 'appResourcesDeployment'
  scope: rg
  params: {
    location: location
    appName: appName
  }
}

output webAppName string = appResources.outputs.webAppName
output webAppUrl string = appResources.outputs.webAppUrl
