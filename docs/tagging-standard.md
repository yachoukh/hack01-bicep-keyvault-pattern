# Tagging standard

Every resource must include these tags at minimum.

| Tag | Required value |
| --- | --- |
| `purpose` | `copilot-hackathon` |
| `owner` | Team or person responsible |
| `costCenter` | Cost center code |
| `environment` | `dev`, `test`, or `prod` |
| `application` | Application or workload name |
| `dataClassification` | `public`, `internal`, or `confidential` |

Use Bicep user-defined types or `@allowed` decorators to validate constrained values wherever possible.
