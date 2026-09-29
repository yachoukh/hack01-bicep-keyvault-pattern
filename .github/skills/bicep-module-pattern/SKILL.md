---
name: bicep-module-pattern
description: Secure Azure Bicep module house pattern for this hackathon. Use when creating, reviewing, documenting, or refactoring Key Vault, storage, private endpoint, diagnostics, or reusable Azure infrastructure modules so generated code follows the repo's parameter, tag, networking, diagnostics, output, and validation conventions.
---

# Secure Bicep module pattern

Use this skill before accepting Copilot-generated Azure Bicep modules in this repo.

## Module shape

1. Set `targetScope = 'resourceGroup'`.
2. Add `metadata description` explaining the module's purpose.
3. Define or reuse a `MandatoryTags` type:

```bicep
type MandatoryTags = {
  purpose: 'copilot-hackathon'
  owner: string
  costCenter: string
  environment: 'dev' | 'test' | 'prod'
  application: string
  dataClassification: 'public' | 'internal' | 'confidential'
}
```

4. Add `@description` to every parameter.
5. Constrain names with `@minLength`, `@maxLength`, and type rules where practical.
6. Pass shared dependencies in as resource IDs rather than hardcoding shared names inside modules.

## Required shared dependency parameters

Most secure private modules should accept:

- `location string = resourceGroup().location`
- `tags MandatoryTags`
- `privateEndpointSubnetId string`
- `privateDnsZoneId string`
- `logAnalyticsWorkspaceId string`

The composition file owns `existing` references to shared resources in `rg-copilot-hack-shared`.

## Private endpoint and DNS pattern

- Key Vault private endpoint `groupIds`: `[ 'vault' ]`.
- Storage blob private endpoint `groupIds`: `[ 'blob' ]`.
- Create `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` as a child of the private endpoint.
- Configure the zone group with the matching private DNS zone ID:
  - Key Vault: `privatelink.vaultcore.azure.net`
  - Blob: `privatelink.blob.core.windows.net`

Do not create a private endpoint without its DNS zone group.

## Diagnostics pattern

- Send diagnostics to the shared Log Analytics workspace ID passed by the composition file.
- Key Vault categories:
  - Logs: `AuditEvent`
  - Metrics: `AllMetrics`
- Blob service categories:
  - Logs: `StorageRead`, `StorageWrite`, `StorageDelete`
  - Metrics: `Transaction`
- Scope storage diagnostics to the blob service child resource, not just the storage account.

## Secure defaults

For Key Vault:

- `enableRbacAuthorization: true`
- `enableSoftDelete: true`
- `softDeleteRetentionInDays: 90`
- `enablePurgeProtection: true`
- `publicNetworkAccess: 'Disabled'`
- `networkAcls.defaultAction: 'Deny'`

For Storage:

- `minimumTlsVersion: 'TLS1_2'`
- `allowSharedKeyAccess: false`
- `allowBlobPublicAccess: false`
- `publicNetworkAccess: 'Disabled'`
- `networkAcls.defaultAction: 'Deny'`
- `supportsHttpsTrafficOnly: true`

## Output rules

Allowed outputs:

- Resource name
- Resource ID
- Service URI or endpoint
- Private endpoint ID

Never output:

- Secret values
- Keys
- Connection strings
- Passwords
- Secure parameter values

## Validation commands

Run the smallest relevant command after each change:

```powershell
az bicep build --file infra/main.bicep
az bicep lint --file infra/main.bicep
az bicep build --file infra/modules/keyvault/main.bicep
az bicep lint --file infra/modules/keyvault/main.bicep
az bicep build --file infra/modules/storage/main.bicep
az bicep lint --file infra/modules/storage/main.bicep
```

The playground intentionally contains insecure-but-valid Bicep. Build it to prove syntax validity, but do not use its lint output as the secure module standard.
