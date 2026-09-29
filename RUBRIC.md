# Judging rubric

| Criterion | Weight | What strong looks like |
|---|---:|---|
| Works end-to-end | 30% | Bicep build/lint pass, pipeline Validate and WhatIf are green, and any approved deploy is repeatable without manual portal fixes. |
| Security posture of the module | 25% | RBAC, purge protection, 90-day soft delete, disabled public access, deny-by-default networking, private endpoint + DNS zone group, diagnostics, safe outputs, and mandatory tags are all present. |
| Copilot leverage | 20% | Team shows useful prompts, iteration, verification of suggestions, MCP/doc grounding, and clear rejection or correction of unsafe Copilot output. |
| Docs and reusability | 15% | Module README, parameters, outputs, naming, tags, and validation commands are clear enough for another team to reuse. |
| Demo and storytelling | 10% | Demo explains the problem, the security decisions, the validation evidence, and what the team learned. |

## What judges will ask

- Which Copilot suggestion did you change or reject, and why?
- How did you prove the template is safe before deploying?
- Where are public network access, network ACLs, private endpoint, and private DNS configured?
- What outputs are intentionally safe, and what would be unsafe to output?
- How does the pipeline prevent accidental deployment?
- What happens if a purge-protected Key Vault is deleted and redeployed?
- If you completed storage, how did you reuse the Key Vault pattern instead of copying blindly?
