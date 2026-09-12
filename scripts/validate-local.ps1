$ErrorActionPreference = "Continue"

function Invoke-IfAvailable {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Tool,

    [Parameter(Mandatory = $true)]
    [scriptblock]$Command
  )

  if (Get-Command $Tool -ErrorAction SilentlyContinue) {
    Write-Host "==> Running $Tool checks"
    & $Command
    if ($LASTEXITCODE -ne 0) {
      throw "$Tool check failed with exit code $LASTEXITCODE"
    }
  } else {
    Write-Warning "$Tool is not installed; skipping."
  }
}

Push-Location $PSScriptRoot\..

Invoke-IfAvailable python {
  Push-Location app
  python -m pip install -r requirements-dev.txt
  python -m pytest -q
  python -m ruff check .
  Pop-Location
}

Invoke-IfAvailable docker {
  docker info | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "Docker CLI is installed, but the Docker daemon is not reachable; skipping image build."
    $global:LASTEXITCODE = 0
    return
  }

  docker build -t ratings-api:local ./app
}

Invoke-IfAvailable helm {
  helm lint ./helm/ratings-api
  helm template ratings-api ./helm/ratings-api -f ./helm/ratings-api/values-dev.yaml | Out-Null
  helm template ratings-api ./helm/ratings-api -f ./helm/ratings-api/values-staging.yaml | Out-Null
  helm template ratings-api ./helm/ratings-api -f ./helm/ratings-api/values-production.yaml | Out-Null
}

Invoke-IfAvailable terraform {
  terraform -chdir=terraform/environments/dev fmt -check -recursive
  terraform -chdir=terraform/environments/dev init -backend=false
  terraform -chdir=terraform/environments/dev validate
}

Invoke-IfAvailable checkov {
  checkov -d . --framework terraform,kubernetes,dockerfile,secrets --quiet
}

if (!(Get-Command checkov -ErrorAction SilentlyContinue) -and (Get-Command python -ErrorAction SilentlyContinue)) {
  Write-Host "==> Installing Checkov in a temporary venv"
  $checkovVenv = Join-Path $env:TEMP "aks-platform-checkov-venv"
  if (!(Test-Path $checkovVenv)) {
    python -m venv $checkovVenv
    & "$checkovVenv\Scripts\python.exe" -m pip install --upgrade pip checkov
  }
  & "$checkovVenv\Scripts\python.exe" -m checkov.main -d . --framework terraform,kubernetes,dockerfile,secrets --quiet
  if ($LASTEXITCODE -ne 0) {
    throw "temporary Checkov scan failed with exit code $LASTEXITCODE"
  }
}

Invoke-IfAvailable gitleaks {
  gitleaks detect --no-git --redact --source .
}

Invoke-IfAvailable trivy {
  trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 .
}

Pop-Location
Write-Host "Local validation finished."
