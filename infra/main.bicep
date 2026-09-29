targetScope = 'resourceGroup'

@description('Azure region for resources. Defaults to the deployment resource group location.')
param location string = resourceGroup().location

@description('Deployment environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Application or workload name.')
param application string

@description('Resource owner tag value.')
param owner string

@description('Cost center tag value.')
param costCenter string

@description('Data classification tag value.')
@allowed([
  'public'
  'internal'
  'confidential'
])
param dataClassification string

@description('Name of the shared resource group created by the facilitator.')
param sharedResourceGroupName string = 'rg-copilot-hack-shared'

@description('Name of the shared Log Analytics workspace.')
param lawName string = 'law-copilot-hack'

@description('Name of the shared virtual network.')
param vnetName string = 'vnet-copilot-hack'

@description('Name of the shared private endpoint subnet.')
param subnetName string = 'snet-private-endpoints'

var mandatoryTags = {
  purpose: 'copilot-hackathon'
  owner: owner
  costCenter: costCenter
  environment: environment
  application: application
  dataClassification: dataClassification
}

resource law 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  scope: resourceGroup(sharedResourceGroupName)
  name: lawName
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' existing = {
  scope: resourceGroup(sharedResourceGroupName)
  name: vnetName
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' existing = {
  parent: vnet
  name: subnetName
}

// TODO: Compose the completed Key Vault module here.
// TODO: In the stretch challenge, compose the Storage module here too.

output starterMessage string = 'Starter template validates shared infrastructure references only. Complete the challenges to add resources.'
output deploymentLocation string = location
output validationTags object = mandatoryTags
output sharedWorkspaceId string = law.id
output privateEndpointSubnetId string = privateEndpointSubnet.id
