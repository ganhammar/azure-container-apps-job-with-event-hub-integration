param keyVaultName string
param containerRegistryToken string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource containerRegistryTokenSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  name: 'container-registry-token'
  parent: keyVault
  properties: {
    value: containerRegistryToken
  }
}
