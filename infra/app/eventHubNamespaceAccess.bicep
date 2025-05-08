param eventHubNamespaceName string
param managedIdentityName string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

resource eventHubsDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, eventHubNamespace.id, 'Azure Event Hubs Data Owner')
  scope: eventHubNamespace
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'f526a384-b230-433a-b45c-95f59c4a2dec'
    ) // Azure Event Hubs Data Owner
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
