# Production-Grade Azure AKS DevSecOps and GitOps Platform

This repository is a deployable Azure DevSecOps reference platform for a real three-environment AKS estate: `dev`, `staging`, and `prod`.

It includes:

- Terraform infrastructure for AKS, ACR, networking, Key Vault, Log Analytics, Application Gateway WAF, PostgreSQL, private DNS, private endpoints, and monitoring.
- A containerized Python FastAPI microservice with unit tests, Docker Compose, health probes, and Prometheus metrics.
- Helm charts and Argo CD GitOps manifests for environment promotion without direct production manifest mutation from CI.
- Azure DevOps YAML pipelines for CI, image build, security scans, Terraform plan/apply, canary release, smoke tests, and manual production approvals.
- SRE runbooks, incident simulations, postmortem template, SLOs, and validation evidence checklist.

## Repository Layout

```text
app/                         Sample production-style microservice
docker-compose.yml           Local development stack
azure-pipelines.yml          Main CI/CD pipeline
pipelines/                   IaC and GitOps supporting pipelines
terraform/                   Azure infrastructure modules and environments
helm/ratings-api/            Helm chart
gitops/                      Argo CD Applications and environment values
k6/                          Load and smoke tests
runbooks/                    Operator runbooks
docs/                        Deployment, security, and evidence docs
```

## Required Cloud Prerequisites

- Azure subscription with Owner or Contributor plus User Access Administrator for initial role assignment.
- Azure DevOps project with service connection to Azure.
- Base64-encoded PFX certificate and password for the HTTPS Application Gateway listener.
- Remote Terraform state storage account. Create it with:

```powershell
./scripts/bootstrap-terraform-state.ps1 -SubscriptionId "<subscription-id>" -Location "eastus" -Prefix "aksdevsecops"
```

- Azure DevOps variable groups:
  - `ado-aks-platform-common`
  - `ado-aks-platform-dev`
  - `ado-aks-platform-staging`
  - `ado-aks-platform-prod`

## Local Validation

Run these checks before opening a PR:

```powershell
./scripts/validate-local.ps1
```

This runs Python tests, Docker build checks, Helm template rendering, Terraform formatting, Terraform validation, and local security scanner commands when the tools are installed.

## Deployment Flow

1. Bootstrap remote Terraform state.
2. Configure Azure DevOps service connections and variable groups.
3. Run the IaC pipeline for `dev`.
4. Deploy Argo CD into the dev AKS cluster.
5. Build and push the app image through the main pipeline.
6. Promote the image tag through GitOps:

```powershell
./scripts/promote-image.ps1 -Environment dev -ImageTag "2026.09.10.1"
./scripts/promote-image.ps1 -Environment staging -ImageTag "2026.09.10.1"
./scripts/promote-image.ps1 -Environment production -ImageTag "2026.09.10.1"
```

7. Production uses Azure DevOps Environment approval before the canary stage continues to full rollout.

## Evidence Status

Local/static proof is included in:

- `docs/evidence/PROJECT_EVIDENCE.md`
- `docs/evidence/LOCAL_VALIDATION_2026-09-11.md`
- `docs/evidence/SECURITY_SCAN_2026-09-11.md`
- `docs/evidence/VALIDATION_CHECKLIST.md`

Authenticated cloud proof is intentionally not claimed by this repository until the pipelines are run against your Azure tenant. Capture screenshots, logs, and exported plans under `docs/evidence/` after you run the deployment.
