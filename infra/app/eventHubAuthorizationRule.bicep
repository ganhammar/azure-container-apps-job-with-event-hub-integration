param eventHubNamespaceName string
param keyVaultName string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource listener 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: eventHubNamespace
  name: 'eh-ar-listener'
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource eventHubConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  name: 'event-hub-connection-string'
  parent: keyVault
  properties: {
    value: listener.listKeys().primaryConnectionString
  }
}
