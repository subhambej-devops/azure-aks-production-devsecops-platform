param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "production")]
  [string]$Environment,

  [Parameter(Mandatory = $true)]
  [string]$ImageTag
)

$ErrorActionPreference = "Stop"

git config user.email "azuredevops-bot@example.com"
git config user.name "Azure DevOps GitOps Bot"
git add "gitops/overlays/$Environment/values.yaml"

git diff --cached --quiet
$hasChanges = $LASTEXITCODE -ne 0

if ($hasChanges) {
  git commit -m "Promote ratings-api $ImageTag to $Environment"
  git push origin HEAD:main
} else {
  Write-Host "No GitOps change to commit."
}

