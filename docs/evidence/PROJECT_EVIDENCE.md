# Project Evidence

## What This Repository Proves

This project is structured as a real Azure AKS DevSecOps platform, not a diagram-only portfolio item.

Reviewer-visible implementation evidence:

- Three Terraform environment roots: `dev`, `staging`, and `prod`.
- Reusable Terraform modules for resource group, networking, private DNS, ACR, Key Vault, managed identity, AKS, Application Gateway WAF, PostgreSQL, Log Analytics, and alerts.
- Remote backend configuration examples for Azure Storage state and locking.
- FastAPI microservice with health, readiness, metrics, tests, Dockerfile, and Docker Compose.
- Helm chart with Namespace, ServiceAccount, SecretProviderClass, Deployment, Rollout, Service, Ingress, HPA, PDB, ResourceQuota, LimitRange, and NetworkPolicy.
- Argo CD GitOps Applications and overlays for dev, staging, and production.
- Production canary rollout using Argo Rollouts.
- Azure DevOps YAML for CI, security scans, SBOM, image push, GitOps promotion, and environment approvals.
- SRE docs: SLO, rollback runbook, Key Vault failure runbook, database outage runbook, and postmortem template.

## Local Validation Evidence

Last local validation on `2026-09-11`:

| Check | Result |
|---|---|
| Python unit tests | Passed, 3 tests |
| Ruff lint | Passed |
| Helm lint | Passed |
| Helm template render | Passed for dev, staging, production |
| Terraform fmt | Passed |
| Terraform init with backend disabled | Passed |
| Terraform validate | Passed for dev, staging, production |
| Checkov Terraform scan | Passed, 62 checks, 0 failed |
| Checkov Dockerfile scan | Passed, 48 checks, 0 failed |
| Trivy vulnerability scan | 0 high or critical findings |
| Trivy secret scan | 0 detected secrets |
| Trivy Terraform/Kubernetes misconfiguration scan | 0 high or critical findings |
| Gitleaks secret scan | No leaks found |
| Azure Pipeline YAML parse | Passed for `azure-pipelines.yml` and `pipelines/iac-plan-apply.yml` |
| Docker Compose config parse | Passed with `.env.example` |
| Generated cache cleanup | `.terraform`, `.pytest_cache`, and `__pycache__` removed from deliverable source |

## Cloud Evidence Still Required

These checks require your Azure subscription and Azure DevOps project:

- Terraform remote backend bootstrap.
- Terraform plan/apply against `dev`, `staging`, and `prod`.
- ACR image push.
- AKS cluster creation.
- Argo CD and Argo Rollouts installation.
- Key Vault CSI and Workload Identity runtime secret mount.
- Azure DevOps production approval.
- Live staging k6 load test.
- Live production smoke test.
- Docker image build and image vulnerability scan on a machine or CI runner with Docker daemon access.

Do not describe the platform as already deployed until those proof items are captured.
