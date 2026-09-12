data "azurerm_client_config" "current" {}

locals {
  normalized_project = replace(lower(var.project), "-", "")
  suffix             = substr(md5("${data.azurerm_client_config.current.subscription_id}-${var.environment}-${var.location}"), 0, 6)
  name_prefix        = "${var.project}-${var.environment}-${var.location_short}"
  compact_prefix     = substr("${local.normalized_project}${var.environment}${local.suffix}", 0, 20)
  common_tags = merge(var.tags, {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  })
}

module "resource_group" {
  source   = "../resource-group"
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source              = "../networking"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_cidr           = var.vnet_cidr
  enable_nat_gateway  = true
  tags                = local.common_tags

  subnets = {
    aks = {
      address_prefixes  = [cidrsubnet(var.vnet_cidr, 4, 0)]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    }
    app-gateway = {
      address_prefixes  = [cidrsubnet(var.vnet_cidr, 4, 1)]
      service_endpoints = []
    }
    private-endpoints = {
      address_prefixes  = [cidrsubnet(var.vnet_cidr, 4, 2)]
      service_endpoints = []
    }
  }
}

module "private_dns" {
  source              = "../private-dns"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  virtual_network_id  = module.networking.vnet_id
  tags                = local.common_tags

  zone_names = [
    "privatelink.azurecr.io",
    "privatelink.vaultcore.azure.net",
    "privatelink.postgres.database.azure.com",
  ]
}

module "log_analytics" {
  source              = "../log-analytics"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = var.environment == "prod" ? 90 : 30
  tags                = local.common_tags
}

module "acr" {
  source              = "../acr"
  name                = substr("${local.compact_prefix}acr", 0, 50)
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags
}

module "key_vault" {
  source                     = "../key-vault"
  name                       = substr("${local.compact_prefix}kv", 0, 24)
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  private_endpoint_subnet_id = module.networking.subnet_ids["private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]
  tags                       = local.common_tags
}

module "workload_identity" {
  source              = "../managed-identity"
  name                = "${local.name_prefix}-ratings-wi"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags
}

module "application_gateway" {
  source                   = "../application-gateway"
  name_prefix              = local.name_prefix
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  subnet_id                = module.networking.subnet_ids["app-gateway"]
  capacity                 = var.environment == "prod" ? 2 : 1
  waf_mode                 = var.environment == "dev" ? "Detection" : "Prevention"
  zones                    = var.environment == "prod" ? ["1", "2", "3"] : null
  ssl_certificate_data     = var.app_gateway_ssl_certificate_data
  ssl_certificate_password = var.app_gateway_ssl_certificate_password
  tags                     = local.common_tags
}

resource "azurerm_user_assigned_identity" "disk_encryption" {
  name                = "${local.name_prefix}-des-mi"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "disk_encryption" {
  name            = "aks-disk-encryption-key"
  key_vault_id    = module.key_vault.id
  key_type        = "RSA-HSM"
  key_size        = 2048
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  expiration_date = "2028-09-11T00:00:00Z"

  depends_on = [azurerm_role_assignment.key_vault_admin]
}

resource "azurerm_disk_encryption_set" "aks" {
  name                = "${local.name_prefix}-des"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption.id
  tags                = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.disk_encryption.id]
  }
}

resource "azurerm_role_assignment" "disk_encryption_key_vault" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.disk_encryption.principal_id
}

module "aks" {
  source                     = "../aks"
  name_prefix                = local.name_prefix
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  subnet_id                  = module.networking.subnet_ids["aks"]
  log_analytics_workspace_id = module.log_analytics.workspace_id
  application_gateway_id     = module.application_gateway.id
  acr_id                     = module.acr.id
  disk_encryption_set_id     = azurerm_disk_encryption_set.aks.id
  private_cluster_enabled    = var.private_cluster_enabled
  system_node_pool           = var.system_node_pool
  user_node_pool             = var.user_node_pool
  sku_tier                   = "Standard"
  zones                      = var.environment == "prod" ? ["1", "2", "3"] : null
  tags                       = local.common_tags
}

module "database" {
  source                     = "../database"
  name_prefix                = local.name_prefix
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  administrator_password     = var.postgres_admin_password
  sku_name                   = var.environment == "prod" ? "GP_Standard_D2s_v3" : "B_Standard_B1ms"
  storage_mb                 = var.environment == "prod" ? 131072 : 32768
  backup_retention_days      = var.environment == "prod" ? 35 : 7
  private_endpoint_subnet_id = module.networking.subnet_ids["private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.postgres.database.azure.com"]
  tags                       = local.common_tags
}

resource "azurerm_role_assignment" "workload_identity_key_vault" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}

resource "azurerm_federated_identity_credential" "ratings_api" {
  name                = "${local.name_prefix}-ratings-api"
  resource_group_name = module.resource_group.name
  parent_id           = module.workload_identity.id
  issuer              = module.aks.oidc_issuer_url
  audience            = ["api://AzureADTokenExchange"]
  subject             = "system:serviceaccount:ratings:ratings-api"
}

resource "azurerm_key_vault_secret" "database_url" {
  name            = "ratings-database-url"
  value           = "postgresql://psqladmin:${var.postgres_admin_password}@${module.database.fqdn}:5432/${module.database.database_name}?sslmode=require"
  key_vault_id    = module.key_vault.id
  content_type    = "connection-string"
  expiration_date = "2028-09-11T00:00:00Z"

  depends_on = [azurerm_role_assignment.workload_identity_key_vault]
}

module "monitor" {
  source              = "../monitor"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  aks_cluster_id      = module.aks.id
  alert_email         = var.alert_email
  tags                = local.common_tags
}
