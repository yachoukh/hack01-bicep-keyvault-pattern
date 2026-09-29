# Naming convention

Use `<abbr>-<app>-<env>-<region short>-<nnn>` for human-readable Azure resource names.

Example: `kv-hack-dev-sdc-001`

| Segment | Meaning | Example |
| --- | --- | --- |
| `abbr` | Resource abbreviation | `kv`, `st`, `pe` |
| `app` | Application or workload | `hack` |
| `env` | Environment | `dev`, `test`, `prod` |
| `region short` | Azure region abbreviation | `sdc` for Sweden Central |
| `nnn` | Sequence or uniqueness suffix | `001` |

Notes:

- Key Vault names are globally unique, 3-24 characters, and allow alphanumeric characters and hyphens. Use a `uniqueString` suffix in deployed names.
- Storage account names are globally unique, 3-24 characters, lowercase letters and numbers only. Remove hyphens.
- Private endpoint names can follow the related resource name with `-pe`.
