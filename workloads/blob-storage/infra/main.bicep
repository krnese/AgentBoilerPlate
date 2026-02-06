targetScope = 'subscription'

param location string = 'eastus2'
param rgName string = 'rg-blob-storage-${location}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

// Generate a unique name for the storage account
// Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
var uniqueSuffix = uniqueString(subscription().subscriptionId, rgName)
var storageAccountName = 'stblob${uniqueSuffix}'

module storageModule 'storage.bicep' = {
  name: 'storageDeployment'
  scope: rg
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

output resourceGroupName string = rg.name
output storageAccountName string = storageModule.outputs.storageAccountName
output storageAccountId string = storageModule.outputs.storageAccountId
output blobEndpoint string = storageModule.outputs.storageAccountPrimaryEndpoints.blob
