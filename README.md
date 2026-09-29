# hack01-bicep-keyvault-pattern

**Format:** 1 day · teams of 2-4 · Azure Bicep + GitHub Copilot  
**Theme:** Build a production-shaped, private-by-default Azure Key Vault module with diagnostics, mandatory tags, and Azure DevOps validation.

Participants start from a lint-clean starter branch and use Copilot to complete a secure infrastructure pattern. The `solution` branch contains the facilitator reference implementation.

---

## Why this scenario works for a hackathon

- **Real customer problem** — teams need repeatable, secure Azure landing-zone modules, not one-off portal deployments.
- **Beginner-friendly surface** — one composition file, one Key Vault module, one parameter file, and a visible pipeline.
- **Deep enough to teach judgment** — Copilot can generate Bicep quickly, but teams must verify API versions, network isolation, RBAC, diagnostics, tags, and secret handling.
- **Safe validation loop** — local `az bicep build`/`lint` and Azure DevOps WhatIf teach infrastructure review without local deployments.
- **Demoable** — judges can inspect compiled Bicep, pipeline evidence, and a short walkthrough of the security decisions.

---

## Azure DevOps environment

| Item | Value |
|---|---|
| Organization | <https://dev.azure.com/azultechlab> |
| Participant project | `Copilot-Hackathon` |
| Facilitator project | `Copilot-Hackathon-Facilitator` |
| Repository | `hack01-bicep-keyvault-pattern` |
| Service connection | `sc-copilot-hack-sandbox` |
| Gated environment | `sandbox` |
| Target resource group | `rg-copilot-hack-deploy` |
| Shared resource group | `rg-copilot-hack-shared` |
| Region | `swedencentral` |

---

## Prerequisites (send to participants before the event)

| Need | Notes |
|---|---|
| Azure CLI + Bicep | Run `az version`, then `az bicep version`. Use `az bicep install` if needed. |
| Visual Studio Code + Copilot | Install GitHub Copilot, GitHub Copilot Chat, and the Bicep extension. |
| Sandbox subscription access | Use only the hackathon sandbox. Do not deploy locally; the pipeline owns WhatIf/deploy. |
| Azure DevOps access | Access to `azultechlab/Copilot-Hackathon` and permission to create branches. |
| Git | Clone from Azure Repos and work on your own branch, for example `users/<alias>/keyvault`. |
| Optional MCP tooling | `.vscode/mcp.json` wires Azure MCP and Microsoft Learn MCP so Copilot can ground Azure API/version and Learn-doc answers instead of guessing. |

Clone from Azure Repos:

```powershell
git clone https://azultechlab@dev.azure.com/azultechlab/Copilot-Hackathon/_git/hack01-bicep-keyvault-pattern
cd hack01-bicep-keyvault-pattern
```

---

## Starter kit

| File or folder | What it is |
|---|---|
| `README.md` | Event overview, prerequisites, agenda, and links. |
| `CHALLENGES.md` | Five-level ladder with points, prompts, success criteria, and hints. |
| `RUBRIC.md` | Standalone judging rubric. |
| `AGENTS.md` | Repo-specific guidance read by Copilot CLI and Copilot coding agent. |
| `.github/copilot-instructions.md` | Thin VS Code Copilot pointer to `AGENTS.md`. |
| `.github/skills/` | Reusable Copilot skills for sandbox conventions and Bicep module patterns. |
| `.vscode/extensions.json` | Recommended VS Code extensions. |
| `.vscode/mcp.json` | Azure MCP and Microsoft Learn MCP server configuration. |
| `docs/naming-convention.md` | Naming rules for Key Vault, storage, and private endpoints. |
| `docs/tagging-standard.md` | Mandatory tag standard used by all modules. |
| `infra/main.bicep` | Resource-group composition file. Starter on `main`, complete on `solution`. |
| `infra/main.bicepparam` | Dev parameter file for pipeline validation. |
| `infra/modules/keyvault/main.bicep` | Key Vault module starter/reference. |
| `infra/modules/storage/` | Stretch storage module, present on the `solution` branch. |
| `playground/` | Planted-defect review exercise. Answer key is on `solution` only. |
| `azure-pipelines.yml` | Validate, WhatIf, and approval-gated Deploy pipeline. |

---

## Local validation

These commands compile and analyze templates only; they do not mutate Azure resources.

```powershell
az bicep build --file infra/main.bicep
az bicep lint --file infra/main.bicep
az bicep build --file infra/modules/keyvault/main.bicep
az bicep lint --file infra/modules/keyvault/main.bicep
az bicep build --file playground/insecure-keyvault.bicep
```

Do **not** run `az deployment group create` locally. The pipeline runs Validate and WhatIf. Deploy runs only from `solution` or `ready/<team>` branches and waits for `sandbox` environment approval.

---

## Challenge ladder

See [CHALLENGES.md](CHALLENGES.md) for the full five-level ladder:

| Level | Points | Theme |
|---|---:|---|
| 1 | 20 | Make it build |
| 2 | 25 | Make it secure |
| 3 | 25 | Prove it |
| 4 | 20 | Production-shaped |
| 5 | 10 | Wildcards |

See [RUBRIC.md](RUBRIC.md) for judging weights and the questions judges will ask.

---

## Suggested agenda (one day)

| Time | Item |
|---|---|
| 09:00 | Kickoff: why secure modules, private endpoints, diagnostics, tags, and Copilot review matter. |
| 09:30 | Preflight: clone, inspect `AGENTS.md`, run `az bicep build`/`lint` on the starter. |
| 10:00 | Level 1: explore the repo and understand the pipeline. |
| 10:45 | Level 2: build the Key Vault module and `.bicepparam`. |
| 12:00 | Lunch / facilitator checkpoint. |
| 13:00 | Level 3: playground review, docs, Validate and WhatIf evidence. |
| 14:30 | Level 4: storage stretch and `ready/<team>` branch workflow. |
| 15:45 | Level 5: wildcard hardening or test harness. |
| 16:30 | Demos, 5 minutes per team. |
| 17:15 | Judging and wrap: what did Copilot accelerate, and what did you verify? |

---

## Planted-defect playground

The `playground/insecure-keyvault.bicep` file is a plausible module written in a hurry. Use Copilot Chat, `/explain`, and MCP-grounded Azure docs to review it, rank the risks, and propose fixes. The answer key is intentionally withheld from the participant branch and lives only on `solution`.

---

## MCP grounding

This repo includes `.vscode/mcp.json`:

- **Azure MCP** can help inspect Azure concepts and resource provider details without inventing API shapes.
- **Microsoft Learn MCP** helps Copilot cite current Learn docs for Bicep, Key Vault private endpoints, diagnostics, and Azure naming/tagging guidance.

MCP does not replace validation. Always run Bicep build/lint and review generated code.

---

## Reference material

- Bicep documentation — <https://learn.microsoft.com/azure/azure-resource-manager/bicep/>
- Bicep CLI commands — <https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-cli>
- Key Vault private link — <https://learn.microsoft.com/azure/key-vault/general/private-link-service>
- Azure Private Endpoint DNS — <https://learn.microsoft.com/azure/private-link/private-endpoint-dns>
- Diagnostic settings — <https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings>
- Azure resource naming guidance — <https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming>
- Azure tagging guidance — <https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging>
- Microsoft Learn MCP server — <https://learn.microsoft.com/training/support/mcp>

Facilitator-only runbook notes live in [FACILITATOR.md](FACILITATOR.md).
