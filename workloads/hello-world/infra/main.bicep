targetScope = 'subscription'

param location string = 'westeurope'
param rgName string = 'rg-hello-world-weu'
// Generate a unique suffix for the app name to avoid global collisions
param appName string = 'hello-world-${uniqueString(subscription().subscriptionId, rgName)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module appModule 'app.bicep' = {
  name: 'appDeployment'
  scope: rg
  params: {
    location: location
    appName: appName
  }
}

output appUrl string = appModule.outputs.appUrl
output webAppName string = appModule.outputs.webAppName
output resourceGroupName string = rg.name
