# Security Scan Evidence - 2026-09-11

## Static Security Gates

| Tool | Scope | Result |
|---|---|---|
| Checkov | Terraform, Kubernetes, Dockerfile, secrets | Passed, 0 failed checks |
| Trivy | Dependencies, secrets, Dockerfile, Terraform, Kubernetes | Passed, 0 high/critical findings |
| Gitleaks | Repository source without Git history | Passed, no leaks found |
| Ruff | Python source | Passed |

## Vulnerabilities Fixed During Hardening

- Removed committed local database credential from `docker-compose.yml`.
- Disabled ACR public network access and enabled zone redundancy, data endpoint, quarantine policy, retention policy, and trust policy.
- Added ACR geo-replication.
- Set AKS private cluster mode for all environments.
- Enabled AKS paid SLA tier, automatic upgrade channel, OIDC issuer, Workload Identity, Azure Policy, local account disablement, disk encryption set, ephemeral OS disks, and minimum 50 pods per node pool.
- Replaced HTTP Application Gateway bootstrap listener with HTTPS listener and secure SSL policy.
- Changed Key Vault to premium SKU, RBAC authorization, public network disabled, purge protection enabled, deny-by-default network ACLs, and private endpoint in-module.
- Added HSM-backed Key Vault key with expiration for AKS disk encryption.
- Added Key Vault secret content type and expiration.
- Moved PostgreSQL private endpoint into the database module and forced geo-redundant backups.
- Narrowed Kubernetes NetworkPolicy egress from all public HTTPS to private/Azure platform ranges.
- Added Argo Rollouts production canary support.

## Remaining Security Boundary

No source-level high/critical static findings remain in local scans. Runtime security still depends on deploying into Azure and capturing live proof from Azure DevOps, AKS, Key Vault CSI, Argo CD, Argo Rollouts, and ACR.

