param location string
param projectName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: take('sa${toLower(replace(projectName, '-', ''))}${uniqueString(resourceGroup().id)}', 24)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  name: 'eventhubcheckpointstore'
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

output name string = storageAccount.name
output containerName string = container.name
