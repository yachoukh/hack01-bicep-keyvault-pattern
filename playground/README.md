# Planted-defect playground

`insecure-keyvault.bicep` is a plausible Key Vault module written in a hurry. It should compile, but it is not production-safe.

## Exercise

1. Ask Copilot to review the module as an Azure infrastructure security reviewer.
2. Find and rank the issues by severity.
3. For each issue, propose a corrected Bicep change.
4. Use Microsoft Learn MCP or Azure MCP to ground any Azure-specific claims.
5. Run:

```powershell
az bicep build --file playground/insecure-keyvault.bicep
```

## Deliverable

Prepare a short review note with:

- Finding title
- Severity
- Evidence from the Bicep file
- Why it matters
- Recommended fix

Do not deploy this module. The goal is review judgment, not Azure mutation.
