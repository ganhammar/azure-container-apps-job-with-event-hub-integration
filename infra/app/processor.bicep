param location string
param managedIdentityName string
param containerAppEnvironmentName string
param containerRegistryNamespacePrefix string
param keyVaultName string
param storageAccountName string
param containerName string
param eventHubNamespaceName string
param eventHubName string
param eventHubConsumerGroupName string

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2025-01-01' existing = {
  name: containerAppEnvironmentName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageAccountName
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

var registry = 'ghcr.io'
resource processor 'Microsoft.App/jobs@2025-01-01' = {
  name: 'ca-processor-job'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      replicaTimeout: 10800 // 3 hours
      triggerType: 'Event'
      eventTriggerConfig: {
        parallelism: 1
        replicaCompletionCount: 1
        scale: {
          rules: [
            {
              name: 'event-hub-trigger'
              type: 'azure-eventhub'
              identity: managedIdentity.id
              metadata: {
                blobContainer: containerName
                storageAccountName: storageAccount.name
                checkPointStrategy: 'blobMetadata'
                consumerGroup: eventHubConsumerGroupName
                eventHubName: eventHubName
                eventHubNamespace: eventHubNamespace.name
                activationUnprocessedEventThreshold: 0
                unprocessedEventThreshold: 64
              }
            }
          ]
        }
      }
      secrets: [
        {
          name: 'container-registry-token'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/container-registry-token'
          identity: managedIdentity.id
        }
      ]
      registries: [
        {
          server: registry
          passwordSecretRef: 'container-registry-token'
          username: '${containerRegistryNamespacePrefix}-token'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'diagnostic-processor'
          image: '${registry}/ganhammar/${containerRegistryNamespacePrefix}/processor:latest'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'BLOB_STORAGE_ACCOUNT_URL'
              value: 'https://${storageAccount.name}.blob.${environment().suffixes.storage}'
            }
            {
              name: 'BLOB_CONTAINER_NAME'
              value: containerName
            }
            {
              name: 'EVENT_HUB_FULLY_QUALIFIED_NAMESPACE'
              value: '${eventHubNamespace.name}.servicebus.windows.net'
            }
            {
              name: 'EVENT_HUB_NAME'
              value: eventHubName
            }
            {
              name: 'EVENT_HUB_CONSUMER_GROUP'
              value: eventHubConsumerGroupName
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: managedIdentity.properties.clientId
            }
          ]
        }
      ]
    }
  }
}

output name string = processor.name
