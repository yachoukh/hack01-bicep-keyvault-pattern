targetScope = 'resourceGroup'

metadata description = 'Demo Key Vault module for review practice. It compiles, but reviewers should decide whether it is safe enough for production.'

type BasicTags = {
  purpose: string
  owner: string
  costCenter: string
  environment: string
  application: string
  dataClassification: string
}

@description('Key Vault name chosen by the team.')
@minLength(3)
@maxLength(24)
param keyVaultName string = 'kv-review-demo-001'

@description('Azure region for the Key Vault and private endpoint.')
param location string = resourceGroup().location

@description('Tags supplied by the deployment.')
param tags BasicTags = {
  purpose: 'copilot-hackathon'
  owner: 'team-review'
  costCenter: 'CC-1234'
  environment: 'dev'
  application: 'hack'
  dataClassification: 'internal'
}

@description('Subnet resource ID for the private endpoint.')
param privateEndpointSubnetId string

@description('Private DNS zone resource ID for vault private link.')
param privateDnsZoneId string

@description('Bootstrap value used by a quick demo script after deployment.')
#disable-next-line secure-secrets-in-params // Playground intentionally contains a plain string secret for review practice.
param bootstrapSecret string = 'TempP@ssw0rd-ChangeMe!'

@description('Principal that should help the team administer the demo vault.')
param adminPrincipalId string

var keyVaultAdministratorRoleId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'
var ownerRoleId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  tags: union(tags, {
    createdBy: 'copilot-demo'
  })
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2025-09-01' = {
  name: '${keyVaultName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}-vault'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-09-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vaultcore'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource broadAdminAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, adminPrincipalId, ownerRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ownerRoleId)
    principalId: adminPrincipalId
    principalType: 'User'
  }
}

resource vaultAdminAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, adminPrincipalId, keyVaultAdministratorRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdministratorRoleId)
    principalId: adminPrincipalId
    principalType: 'User'
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
#disable-next-line outputs-should-not-contain-secrets // Playground intentionally echoes a sensitive value for review practice.
output bootstrapSecretForPipeline string = bootstrapSecret
output resourceGroupOwnerAssignmentId string = broadAdminAssignment.id
output vaultAdminAssignmentId string = vaultAdminAssignment.id
