param location string
param projectName string

var keyVaultName = '${take('kv${toLower(replace(projectName, '-', ''))}${uniqueString(resourceGroup().id)}', 23)}2'
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableSoftDelete: true
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

output name string = keyVault.name
