param location string
@minLength(3)
param projectName string
param containerRegistryNamespacePrefix string
@secure()
param containerRegistryToken string

module managedIdentity './core/identity/managedIdentity.bicep' = {
  name: 'managedIdentity'
  params: {
    location: location
    projectName: projectName
  }
}

module logAnalytics './core/monitor/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    projectName: projectName
  }
}

module keyVault './core/keyVault/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    projectName: projectName
  }
}

module keyVaultAccess './app/keyVaultAccess.bicep' = {
  name: 'keyVaultAccess'
  params: {
    keyVaultName: keyVault.outputs.name
    managedIdentityName: managedIdentity.outputs.name
  }
}

module storageAccount './core/storage/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    projectName: projectName
  }
}

module storageAccountAccess './app/storageAccountAccess.bicep' = {
  name: 'storageAccountAccess'
  params: {
    storageAccountName: storageAccount.outputs.name
    managedIdentityName: managedIdentity.outputs.name
  }
}

module containerRegistryTokenSecret './core/keyVault/containerRegistryTokenSecret.bicep' = {
  name: 'containerRegistryTokenSecret'
  params: {
    keyVaultName: keyVault.outputs.name
    containerRegistryToken: containerRegistryToken
  }
}

module eventHub './core/eventHub/eventHub.bicep' = {
  name: 'eventHub'
  params: {
    location: location
    projectName: projectName
  }
}

module eventHubNamespaceAccess './app/eventHubNamespaceAccess.bicep' = {
  name: 'eventHubNamespaceAccess'
  params: {
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
    managedIdentityName: managedIdentity.outputs.name
  }
}

module eventHubConsumerGroup './app/eventHubConsumerGroup.bicep' = {
  name: 'eventHubConsumerGroup'
  params: {
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
    eventHubName: eventHub.outputs.eventHubName
  }
}

module eventHubAuthorizationRule './app/eventHubAuthorizationRule.bicep' = {
  name: 'eventHubAuthorizationRule'
  params: {
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
  }
}

module containerAppEnvironment './core/host/containerAppEnvironment.bicep' = {
  name: 'containerAppEnvironment'
  params: {
    location: location
    projectName: projectName
    logAnalyticsWorkspaceName: logAnalytics.outputs.name
    managedIdentityName: managedIdentity.outputs.name
  }
}

module processor './app/processor.bicep' = {
  name: 'processor'
  params: {
    location: location
    managedIdentityName: managedIdentity.outputs.name
    containerAppEnvironmentName: containerAppEnvironment.outputs.name
    containerRegistryNamespacePrefix: containerRegistryNamespacePrefix
    keyVaultName: keyVault.outputs.name
    eventHubName: eventHub.outputs.eventHubName
    storageAccountName: storageAccount.outputs.name
    containerName: storageAccount.outputs.containerName
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
    eventHubConsumerGroupName: eventHubConsumerGroup.outputs.name
  }
  dependsOn: [
    keyVaultAccess
    storageAccountAccess
    eventHubNamespaceAccess
  ]
}
