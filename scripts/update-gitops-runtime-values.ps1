param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "production")]
  [string]$Environment,

  [Parameter(Mandatory = $true)]
  [string]$AcrLoginServer,

  [Parameter(Mandatory = $true)]
  [string]$WorkloadIdentityClientId,

  [Parameter(Mandatory = $true)]
  [string]$KeyVaultName,

  [Parameter(Mandatory = $true)]
  [string]$TenantId,

  [Parameter(Mandatory = $false)]
  [string]$HostName = ""
)

$ErrorActionPreference = "Stop"

$valuesPath = Join-Path $PSScriptRoot "..\gitops\overlays\$Environment\values.yaml"
if (!(Test-Path $valuesPath)) {
  throw "Missing GitOps values file: $valuesPath"
}

$content = Get-Content -Raw -LiteralPath $valuesPath
$content = $content -replace 'repository: "?.*?/ratings-api"?', "repository: $AcrLoginServer/ratings-api"
$content = $content -replace 'workloadIdentityClientId: ".*"', "workloadIdentityClientId: `"$WorkloadIdentityClientId`""
$content = $content -replace 'keyVaultName: ".*"', "keyVaultName: `"$KeyVaultName`""
$content = $content -replace 'tenantId: ".*"', "tenantId: `"$TenantId`""

if ($HostName -ne "") {
  $content = $content -replace 'host: .*', "host: $HostName"
}

Set-Content -LiteralPath $valuesPath -Value $content -NoNewline

Write-Host "Updated runtime GitOps values for $Environment."
Write-Host "Review, commit, and let Argo CD reconcile the environment."
