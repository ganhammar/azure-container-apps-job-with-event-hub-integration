param location string
param projectName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${projectName}'
  location: location
}

output name string = managedIdentity.name
