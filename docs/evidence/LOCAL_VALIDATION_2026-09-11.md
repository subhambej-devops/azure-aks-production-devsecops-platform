# Local Validation Evidence - 2026-09-11

Working directory:

```text
C:\Users\sujoy\Documents\Codex\2026-09-10\files-pasted-by-the-user-project\outputs\azure-aks-production-devsecops-platform
```

## Commands Run

```powershell
python -m pytest -q
python -m ruff check .
helm lint ./helm/ratings-api
helm template ratings-api ./helm/ratings-api -f ./helm/ratings-api/values-dev.yaml
helm template ratings-api ./helm/ratings-api -f ./helm/ratings-api/values-staging.yaml
helm template ratings-api ./helm/ratings-api -f ./helm/ratings-api/values-production.yaml
terraform -chdir=terraform/environments/dev validate
terraform -chdir=terraform/environments/staging validate
terraform -chdir=terraform/environments/prod validate
checkov -d . --framework terraform,kubernetes,dockerfile,secrets --quiet
gitleaks detect --no-git --redact --source .
trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 .
python -c "import pathlib, yaml; files=['azure-pipelines.yml','pipelines/iac-plan-apply.yml']; [yaml.safe_load(pathlib.Path(f).read_text()) for f in files]"
docker compose --env-file .env.example config
./scripts/validate-local.ps1
```

## Results

| Gate | Result |
|---|---|
| Python unit tests | Passed: 3 tests |
| Ruff | Passed |
| Helm lint | Passed |
| Helm template render | Passed for dev, staging, production |
| Terraform validate | Passed for dev, staging, production |
| Checkov Terraform | Passed: 62 checks, 0 failed |
| Checkov Dockerfile | Passed: 48 checks, 0 failed |
| Gitleaks | Passed: no leaks found |
| Trivy | Passed: 0 high/critical vulnerabilities, secrets, or misconfigurations |
| Azure Pipeline YAML parse | Passed |
| Docker Compose config parse | Passed with `.env.example` |
| `scripts/validate-local.ps1` | Passed |

## Known Local Limitation

Docker CLI is installed, but the Docker Desktop Linux engine was not reachable:

```text
failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine
```

Because of that local machine state, Docker image build and image scan were not executed locally. The Azure DevOps pipeline includes Docker build, Trivy image scan, SBOM generation, and ACR push for hosted validation.
