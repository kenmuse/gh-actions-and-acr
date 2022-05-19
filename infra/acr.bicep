@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@secure()
@description('An optional principal identifier. If provided, assigns the principal the AcrPush role in the registry')
param principalId string =''

resource registry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

// Contributor built-in role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

// AcrPush built-in role
resource acrPushRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '8311e382-0749-4cb8-b61a-304f252e45ec'
}

// If a principal is provided, assign it the AcrPush role in the registry.
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2018-01-01-preview' = if (!empty(principalId)) {
  name: guid(registry.id, subscription().id)
  scope: registry
  properties: {
    principalId: principalId
    roleDefinitionId: acrPushRoleDefinition.id
  }
}

// Output the login server property for later use
output loginServer string = registry.properties.loginServer

// This is generally a bad idea as it can expose secure credentials through an
// insecure channel. Since we're using OIDC instead of the 'admin user', we
// eliminate a reason to need these values. Avoiding the need to have an
// Admin user increases our security.
//output pwd string = registry.listCredentials().passwords[0].value
//output user string = registry.listCredentials().username
