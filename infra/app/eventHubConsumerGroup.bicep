param eventHubNamespaceName string
param eventHubName string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' existing = {
  name: eventHubName
  parent: eventHubNamespace
}

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-05-01-preview' = {
  parent: eventHub
  name: 'diagnostic-processor'
  properties: {}
}

output name string = eventHubConsumerGroup.name
