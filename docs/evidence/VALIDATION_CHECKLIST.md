# Validation Checklist

## Local Proof

Run:

```powershell
./scripts/validate-local.ps1
```

Capture:

- Python test output.
- Docker image build output.
- Helm lint output.
- Terraform `fmt` and `validate` output.
- Trivy, Checkov, and Semgrep scan artifacts.

## Authenticated Azure Proof

Capture after real deployment:

- Terraform plan and apply logs for `dev`, `staging`, and `prod`.
- Azure Portal screenshots for AKS, ACR, Key Vault, Application Gateway WAF, Log Analytics, and PostgreSQL.
- Azure DevOps pipeline run link.
- Azure DevOps Environment approval screenshot for production.
- Argo CD sync screenshot for each environment.
- `kubectl get pods,svc,ingress,hpa,pdb -n ratings`.
- `kubectl describe secretproviderclass ratings-api-kv -n ratings`.
- Smoke test output from production.
- k6 load test summary from staging.
- Argo Rollouts canary status:

```powershell
kubectl argo rollouts get rollout ratings-api -n ratings
```

## Evidence Boundary

Do not claim production deployment success until these Azure-dependent checks are captured from the target tenant.

