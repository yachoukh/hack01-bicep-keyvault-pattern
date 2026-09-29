targetScope = 'resourceGroup'

metadata description = 'Starter Key Vault module. Complete this module during the hackathon.'

type MandatoryTags = {
  purpose: 'copilot-hackathon'
  owner: string
  costCenter: string
  environment: 'dev' | 'test' | 'prod'
  application: string
  dataClassification: 'public' | 'internal' | 'confidential'
}

@description('Name that the completed Key Vault module will use.')
param keyVaultName string

@description('Azure region for the completed Key Vault module.')
param location string = resourceGroup().location

@description('Mandatory resource tags. Keep this type when replacing the starter with real resources.')
param tags MandatoryTags

// TODO: Add Microsoft.KeyVault/vaults with RBAC authorization, soft delete, purge protection, disabled public access, and deny-by-default network ACLs.
// TODO: Add a private endpoint with groupId vault and a private DNS zone group.
// TODO: Add diagnostic settings to the shared Log Analytics workspace for AuditEvent and AllMetrics.

output starterKeyVaultName string = keyVaultName
output starterLocation string = location
output starterTags object = tags
