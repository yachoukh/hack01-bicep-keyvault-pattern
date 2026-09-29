# Challenges

Use Copilot as your pair programmer. Prefer small prompts, review every suggestion, and run validation often. Teams can stop at any level, but judges award up to 100 points across the ladder.

> Safety rule: do not run local `az deployment ... create`. Use local Bicep build/lint and the Azure DevOps pipeline for Validate and WhatIf. Deploy only through a `ready/<team>` branch and the `sandbox` environment approval.

## Level 1 — Make it build (20 pts)

### Challenge 1.1 — Explore the repo with Copilot

**Goal:** Understand the starter files, shared infrastructure, naming rules, tags, MCP setup, and pipeline.

**Suggested Copilot prompts**

- Chat: `Summarize this repository and explain the deployment flow.`
- `@workspace Where are the Bicep entry point and module files?`
- `/explain` on `infra/main.bicep`, `azure-pipelines.yml`, and `AGENTS.md`.
- Copilot Edits/agent mode: `Create a short checklist of files I need to modify for the Key Vault challenge.`
- With MCP enabled: `Use Microsoft Learn MCP to verify the current Key Vault private endpoint guidance.`

**Success criteria**

- You can explain what `main.bicep`, `main.bicepparam`, and the Key Vault module do.
- You can identify the shared Log Analytics workspace, VNet, subnet, and private DNS zone names.
- You can explain why local build/lint is safe and local deployment is not part of the exercise.

**Hints**

- Start in `README.md`, `AGENTS.md`, `.github/copilot-instructions.md`, and `docs/`.
- Ask Copilot to compare the starter branch with the intended architecture described here.
- MCP is useful for grounding Azure API versions and Learn docs; it does not prove your Bicep builds.

### Challenge 1.2 — Get the starter clean

**Goal:** Confirm the starter repository compiles before you change it.

**Suggested Copilot prompts**

- Chat: `Explain what az bicep build and az bicep lint prove, and what they do not prove.`
- Chat: `Explain this Bicep lint output and propose the smallest safe fix.`

**Success criteria**

- `az bicep build --file infra/main.bicep` succeeds.
- `az bicep lint --file infra/main.bicep` has no errors.
- `az bicep build --file infra/modules/keyvault/main.bicep` succeeds on the starter.

**Hints**

- Do not fix unrelated architecture while clearing lint.
- Keep the starter/solution split intact. The `main` branch is intentionally incomplete.

## Level 2 — Make it secure (25 pts)

### Challenge 2.1 — Generate a secure Key Vault module

**Goal:** Replace the starter in `infra/modules/keyvault/main.bicep` with a secure module.

Requirements:

- RBAC authorization enabled
- Soft delete retention set to 90 days
- Purge protection enabled
- `publicNetworkAccess` disabled
- Network ACL default action `Deny`
- Private endpoint using groupId `vault`
- Private DNS zone group for `privatelink.vaultcore.azure.net`
- Diagnostic settings to Log Analytics for `AuditEvent` and `AllMetrics`
- `tags` parameter validates mandatory tags: `purpose`, `owner`, `costCenter`, `environment`, `application`, `dataClassification`
- Outputs: Key Vault name, ID, URI, and private endpoint ID; do not output secrets

**Pitfall: why does my redeploy fail after teardown?** Soft delete keeps deleted Key Vault names reserved for 90 days, and purge protection prevents purging them. If the deterministic vault name was deleted during teardown, recover it with `az keyvault recover --name <vault-name> --resource-group rg-copilot-hack-deploy` or ask your facilitator for a new vault name.

**Suggested Copilot prompts**

- Chat: `Generate a Bicep Key Vault module using RBAC, private endpoint, private DNS zone group, diagnostics to Log Analytics, and the mandatory tag type from the repository standards.`
- Inline: write `type MandatoryTags =` and ask Copilot to complete it.
- `/explain` on Copilot's generated network ACLs and private endpoint connection.
- `/tests` or Chat: `How can I validate this Bicep module without deploying Azure resources?`
- `@workspace Check my Key Vault module against docs/tagging-standard.md and AGENTS.md.`
- With Microsoft Learn MCP: `Verify the current Key Vault Bicep resource properties for RBAC, purge protection, and public network access.`

**Success criteria**

- `az bicep build --file infra/modules/keyvault/main.bicep` succeeds.
- `az bicep lint --file infra/modules/keyvault/main.bicep` has no errors.
- Parameters have `@description` decorators.
- No output exposes secrets, keys, connection strings, or secure parameter values.

**Hints**

- Use `existing` resources in the composition file, not inside the module unless needed.
- Key Vault names have a 24-character limit and must be globally unique.
- Private endpoint and private DNS zone group are a pair; one without the other is not enough for private name resolution.

### Challenge 2.2 — Create a `.bicepparam` file

**Goal:** Fill `infra/main.bicepparam` with dev values.

**Suggested Copilot prompts**

- Chat: `Create dev parameters for this Bicep file using swedencentral, owner hackathon, cost center CC-1234, application hack, and internal data classification.`
- Inline: start with `using './main.bicep'`.
- `@workspace Verify that my parameter file matches allowed values in infra/main.bicep.`

**Success criteria**

- Parameter file builds with `az bicep build --file infra/main.bicep`.
- Values match the hackathon standard.
- The target resource group is supplied by the pipeline, not hardcoded as a deployment target in the parameter file.

**Hints**

- Never put secrets in `.bicepparam` files.
- If you add a `nameSuffix`, understand that it changes deterministic names. Leave it empty unless a facilitator tells you otherwise.

## Level 3 — Prove it (25 pts)

### Challenge 3.1 — Review the planted-defect playground

**Goal:** Use Copilot to review `playground/insecure-keyvault.bicep`, find and rank security/configuration issues, and propose fixes.

**Suggested Copilot prompts**

- Chat: `Review playground/insecure-keyvault.bicep as an Azure security reviewer. Rank findings by severity and cite the exact Bicep lines.`
- Chat: `For each finding, propose the smallest Bicep fix and the validation command I should run.`
- With MCP enabled: `Use Microsoft Learn MCP to verify whether these Key Vault and private endpoint settings are secure.`

**Success criteria**

- You identify at least five distinct defects.
- You rank each issue by severity and explain the blast radius.
- You propose fixes without turning the exercise into a deploy.
- `az bicep build --file playground/insecure-keyvault.bicep` succeeds, proving the defects are security/configuration flaws rather than syntax errors.

**Hints**

- Look for network exposure, diagnostics, RBAC scope, secret handling, deletion protection, and outputs.
- A valid template can still be unsafe.

### Challenge 3.2 — Generate module documentation

**Goal:** Create `infra/modules/keyvault/README.md` with parameter and output tables.

**Suggested Copilot prompts**

- Chat: `Read the Key Vault Bicep module and generate README tables for parameters and outputs.`
- Copilot Edits: `Update only infra/modules/keyvault/README.md with usage, parameters, outputs, and validation commands.`

**Success criteria**

- README includes purpose, usage example, parameter table, output table, and validation commands.
- No secrets or tenant-specific values are documented.
- The docs mention private endpoint, private DNS zone group, diagnostics, and safe outputs.

**Hints**

- Ask Copilot to keep docs beginner-friendly.
- Documentation should reflect the actual Bicep, not an idealized design.

### Challenge 3.3 — Make lint pass and run WhatIf through the pipeline

**Goal:** Confirm validation is clean and use Azure DevOps to review a WhatIf.

**Suggested Copilot prompts**

- Chat: `Explain each Bicep lint warning and propose the smallest fix.`
- `@workspace Explain the Deploy stage condition in azure-pipelines.yml and when it runs.`
- Copilot agent mode: `Fix Bicep lint errors without changing the architecture.`

**Success criteria**

- Build and lint pass locally.
- Azure Pipelines Validate passes.
- WhatIf stage runs against `rg-copilot-hack-deploy`.
- You can explain what resources WhatIf plans to create or update.

**Hints**

- Do not run local deployments.
- Use pipeline logs to copy exact commands back into your local terminal.

## Level 4 — Production-shaped (20 pts)

### Challenge 4.1 — Add the storage account module and composition

**Goal:** Add `infra/modules/storage/main.bicep`, document it, and compose both modules in `infra/main.bicep`.

Requirements:

- Storage account with blob private endpoint using groupId `blob`
- `minimumTlsVersion` set to `TLS1_2`
- `allowSharedKeyAccess` set to `false`
- `allowBlobPublicAccess` set to `false`
- Public network access disabled and network ACLs deny by default
- Diagnostic settings on the blob service
- Private DNS zone group for `privatelink.blob.core.windows.net`
- Reuse the mandatory tag type and naming convention from the Key Vault work

**Suggested Copilot prompts**

- Chat: `Create a storage account Bicep module that follows the same private endpoint and diagnostics pattern as the Key Vault module.`
- `@workspace Reuse the mandatory tag type and naming convention for storage.`
- `/explain` on the blob service diagnostics resource.
- With Azure MCP: `Check current Storage Account Bicep properties for disabling shared keys and public access.`

**Success criteria**

- Storage module builds and lints.
- `infra/main.bicep` can deploy Key Vault and optionally Storage with `deployStorage`.
- Storage outputs expose only name, ID, blob endpoint, and private endpoint ID.

**Hints**

- Storage account names must be lowercase alphanumeric and no longer than 24 characters.
- Reusing the tag type is better than inventing a second standard.

### Challenge 4.2 — Use the production pipeline path

**Goal:** Push completed work to `ready/<team>` and use the `sandbox` environment approval flow.

**Suggested Copilot prompts**

- Chat: `Explain why this pipeline runs Deploy only for solution or ready branches.`
- Chat: `Summarize the risk of changing nameSuffix and deterministic naming before I open my ready branch.`

**Success criteria**

- Validate and WhatIf are green on your branch.
- Deploy waits for `sandbox` approval.
- You can explain why `nameSuffix = ''` keeps existing seeded names stable.

**Hints**

- Never change the naming scheme casually. A naming change can create duplicate resources instead of updating existing ones.
- Facilitators approve or reject deployment after reviewing WhatIf.

## Level 5 — Wildcards (10 pts)

Pick one or more advanced hardening ideas.

**Goal:** Show responsible creativity without breaking the core pattern.

Options:

- Add a Bicep test or WhatIf assertion harness that checks for private endpoint, diagnostics, and safe outputs.
- Add a custom lint rule or stricter analyzer configuration through `bicepconfig.json`.
- Parameterize for multiple environments while keeping mandatory tags constrained.
- Publish the module to a private Bicep registry and consume a versioned module.
- Add generated diagrams or a short architecture decision record explaining the security posture.

**Suggested Copilot prompts**

- Chat: `Design a lightweight Bicep validation harness for this module that does not deploy Azure resources.`
- Chat: `Propose a bicepconfig.json rule set that catches insecure outputs and hardcoded secrets.`
- Chat: `How should this module be versioned if published to an Azure Container Registry Bicep registry?`

**Success criteria**

- The wildcard is demonstrable within the hackathon timebox.
- It does not weaken the Key Vault or storage security requirements.
- It includes validation evidence or clear docs.

**Hints**

- Prefer one polished wildcard over three half-finished ideas.
- Judges reward verification and trade-off thinking, not just generated code volume.
