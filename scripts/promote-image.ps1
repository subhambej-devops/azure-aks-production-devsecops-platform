param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "production")]
  [string]$Environment,

  [Parameter(Mandatory = $true)]
  [string]$ImageTag
)

$ErrorActionPreference = "Stop"

$valuesPath = Join-Path $PSScriptRoot "..\gitops\overlays\$Environment\values.yaml"
if (!(Test-Path $valuesPath)) {
  throw "Missing GitOps values file: $valuesPath"
}

$content = Get-Content -Raw -LiteralPath $valuesPath
$updated = $content -replace 'tag: ".*"', "tag: `"$ImageTag`""
Set-Content -LiteralPath $valuesPath -Value $updated -NoNewline

Write-Host "Updated $valuesPath to image tag $ImageTag"
Write-Host "Commit this change and let Argo CD sync the environment."

