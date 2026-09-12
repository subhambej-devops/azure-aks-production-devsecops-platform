param(
  [Parameter(Mandatory = $true)]
  [string]$SubscriptionId,

  [Parameter(Mandatory = $false)]
  [string]$Location = "eastus",

  [Parameter(Mandatory = $false)]
  [string]$Prefix = "aksdevsecops"
)

$ErrorActionPreference = "Stop"

$resourceGroupName = "rg-$Prefix-tfstate"
$storageAccountName = ("$Prefix" + "tf" + (Get-Random -Minimum 10000 -Maximum 99999)).ToLower()
$containerName = "tfstate"

az account set --subscription $SubscriptionId
az group create --name $resourceGroupName --location $Location --tags purpose=terraform-state project=aks-devsecops | Out-Null
az storage account create `
  --resource-group $resourceGroupName `
  --name $storageAccountName `
  --location $Location `
  --sku Standard_GRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  --https-only true `
  --tags purpose=terraform-state project=aks-devsecops | Out-Null

az storage container create `
  --name $containerName `
  --account-name $storageAccountName `
  --auth-mode login | Out-Null

Write-Host "Terraform backend created."
Write-Host "resource_group_name  = `"$resourceGroupName`""
Write-Host "storage_account_name = `"$storageAccountName`""
Write-Host "container_name       = `"$containerName`""

