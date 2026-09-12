# Deployment Runbook

## 1. Bootstrap Terraform State

```powershell
./scripts/bootstrap-terraform-state.ps1 -SubscriptionId "<subscription-id>" -Location "eastus" -Prefix "aksdevsecops"
```

Copy the generated backend values into:

- `terraform/backend/dev.azurerm.tfbackend`
- `terraform/backend/staging.azurerm.tfbackend`
- `terraform/backend/prod.azurerm.tfbackend`

Each file should keep a different `key`.

## 2. Configure Azure DevOps

Create:

- Azure service connection: `sc-azure-aks-platform`
- ACR service connection value in variable group: `azureContainerRegistryServiceConnection`
- Environment approvals for `Production`
- Branch policy requiring PR validation before merge to `main`
- Variable groups for common and environment-specific values

Required secret variables:

- `postgresAdminPassword`
- `appGatewaySslCertificateData`
- `appGatewaySslCertificatePassword`
- `azureContainerRegistryServiceConnection`

## 3. Provision Infrastructure

Run `pipelines/iac-plan-apply.yml` for each environment in order:

```text
dev -> staging -> prod
```

Production apply should require an environment approval.

## 4. Install Argo CD

```powershell
az aks get-credentials -g "<resource-group>" -n "<aks-name>"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl apply -f gitops/base/project.yaml
kubectl apply -f gitops/overlays/dev/application.yaml
```

Repeat the final apply command from the target cluster for `staging` and `production`.

## 5. Update Runtime Values

Replace placeholders in `gitops/overlays/*/values.yaml` using Terraform outputs:

- `image.repository`
- `workloadIdentityClientId`
- `keyVaultName`
- `tenantId`

Example:

```powershell
./scripts/update-gitops-runtime-values.ps1 `
  -Environment dev `
  -AcrLoginServer "<acr-login-server>" `
  -WorkloadIdentityClientId "<client-id>" `
  -KeyVaultName "<key-vault-name>" `
  -TenantId "<tenant-id>" `
  -HostName "ratings-dev.example.com"
```

## 6. Release

Merge application changes into `main`. The pipeline:

1. Runs tests and security scans.
2. Builds the image.
3. Generates SBOM.
4. Pushes to ACR.
5. Commits GitOps image-tag updates.
6. Lets Argo CD reconcile AKS.

Production uses an Argo Rollouts canary with 20%, 50%, and 100% rollout steps.
