# AGENTS.md

Copilot CLI and Copilot coding agent read this file. Treat it as the repo-specific operating guide for hack01.

## Scope and safety

- Work only in this repository unless a task explicitly names a read-only reference file.
- Never run local `az deployment group create`, `az deployment sub create`, or any command that mutates Azure.
- Use local `az bicep build` and `az bicep lint` for validation. Use Azure DevOps pipeline WhatIf/deploy paths for Azure-side checks.
- Never commit secrets, connection strings, PATs, subscription IDs, or real tenant-specific credentials.

## Bicep conventions

- Target scope is `resourceGroup`.
- Add `@description` to every parameter.
- Prefer constrained Bicep user-defined types and `@allowed` decorators for participant-facing inputs.
- Use current stable resource API versions. If an extension resource requires an older preview shape, document the reason with a one-line analyzer suppression.
- Shared infrastructure is referenced as `existing` resources in `rg-copilot-hack-shared` from the composition file.
- Modules receive resource IDs for shared subnet, private DNS zone, and Log Analytics workspace; modules should not discover those names themselves.

## Mandatory tags

Every deployed resource must receive this mandatory tag set:

| Tag | Rule |
|---|---|
| `purpose` | `copilot-hackathon` |
| `owner` | Non-empty team/person value |
| `costCenter` | Hackathon examples use `CC-1234` |
| `environment` | `dev`, `test`, or `prod` |
| `application` | Non-empty workload name; hackathon default is `hack` |
| `dataClassification` | `public`, `internal`, or `confidential` |

Reuse the same `MandatoryTags` type across Key Vault and storage patterns.

## Naming convention

- Region is `swedencentral`; region abbreviation is `sdc`.
- Human-readable pattern: `<abbr>-<application>-<environment>-<region-abbrev>-<suffix>`.
- Key Vault names are max 24 characters and may contain letters, numbers, and hyphens.
- Storage account names are max 24 characters, lowercase, and alphanumeric only.
- The `nameSuffix` behavior in `infra/main.bicep` is load-bearing. `nameSuffix = ''` must keep the existing deployed names:
  - Key Vault: `kv-hack-dev-sdc-svmu5i`
  - Storage account: `sthackdevsdcsvmu5ipj`
- Do not change the naming scheme without WhatIf evidence and explicit facilitator approval.

## Region and shared resources

- Use `swedencentral`.
- Target resource group: `rg-copilot-hack-deploy`.
- Shared resource group: `rg-copilot-hack-shared`.
- Shared Log Analytics workspace: `law-copilot-hack`.
- Shared VNet: `vnet-copilot-hack`.
- Shared private endpoint subnet: `snet-private-endpoints`.
- Key Vault private DNS zone: `privatelink.vaultcore.azure.net`.
- Blob private DNS zone: `privatelink.blob.core.windows.net`.

## Always verify Copilot suggestions

- API versions are valid for the resource type.
- Secret-like parameters use `@secure()` and are never echoed in outputs.
- No output returns secrets, keys, connection strings, passwords, or secure parameter values.
- Key Vault uses RBAC, 90-day soft delete, purge protection, disabled public network access, and deny-by-default network ACLs.
- Private endpoint `groupIds` are correct: `vault` for Key Vault and `blob` for storage.
- Every private endpoint has a matching private DNS zone group.
- Diagnostic settings send the required categories/metrics to the shared Log Analytics workspace.
- Storage disables shared keys, blob public access, and public network access.
- Build and lint commands pass after each meaningful change.

## Never do

- Never run local Azure deployments against the sandbox.
- Never put secrets in `.bicepparam`, docs, outputs, or examples.
- Never change deterministic naming or `nameSuffix` behavior casually.
- Never remove the approval-gated `sandbox` environment from the deploy stage.
- Never leak solution-only answer keys onto the participant `main` branch.
