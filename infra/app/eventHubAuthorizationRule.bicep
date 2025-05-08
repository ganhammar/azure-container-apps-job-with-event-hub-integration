param eventHubNamespaceName string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
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
