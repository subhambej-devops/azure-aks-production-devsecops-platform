# Security Controls

## Identity

- AKS local admin account disabled.
- Microsoft Entra Workload ID enabled.
- User-assigned managed identity used by `ratings-api`.
- Key Vault access uses Azure RBAC, not access policies.

## Secrets

- Kubernetes manifests do not store database credentials.
- Azure Key Vault holds `ratings-database-url`.
- Secrets Store CSI Driver syncs runtime secret into the pod.

## Network

- Environment-specific VNet CIDR ranges.
- Dedicated AKS, Application Gateway, and private endpoint subnets.
- Private endpoints for ACR, Key Vault, and PostgreSQL.
- Application Gateway WAF enabled.
- Dev may expose selected public access for bootstrap speed; staging and prod default private.

## CI/CD

- Unit tests and lint.
- Semgrep SAST.
- Trivy filesystem and image scans.
- SBOM generation with Syft.
- Checkov for Terraform.
- Terraform plan before apply.
- Production deploy via Azure DevOps Environment approval.

## Kubernetes

- Non-root container runtime.
- Dropped Linux capabilities.
- Read-only root filesystem.
- Liveness, readiness, and startup probes.
- ResourceQuota and LimitRange.
- HPA and PodDisruptionBudget.
- NetworkPolicy for explicit ingress and restricted egress to private/Azure platform ranges.

## Production Release Guardrail

- Production uses Argo Rollouts canary steps.
- Azure DevOps `Production` environment should require manual approval.
- CI updates GitOps files and lets Argo CD reconcile production instead of directly applying manifests.
