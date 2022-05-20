////////////////
// Parameters
////////////////
@minLength(5)
@maxLength(50)
@description('Globally unique name for the registry. Default is a unique name based on the Resource Group.')
param name string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry. Default matches the resource group')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param sku string = 'Basic'

@secure()
@description('An optional principal identifier. If provided, assigns the principal the AcrPush role in the registry')
param principalId string =''

////////////////
// Resources
////////////////
resource registry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: name
  location: location
  sku: {
    name: sku
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

////////////////
// Outputs
////////////////

// Output the login server property for later use
output loginServer string = registry.properties.loginServer

// The items below are generally a bad idea as they can expose secure credentials 
// through an insecure channel. Since we're using OIDC instead of the 'admin user',
// we eliminate a reason to need these values. Avoiding the need to have an
// Admin user increases our security.
//output pwd string = registry.listCredentials().passwords[0].value
//output user string = registry.listCredentials().username
