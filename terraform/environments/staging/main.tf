module "platform" {
  source = "../../modules/platform"

  environment                          = "staging"
  location                             = var.location
  location_short                       = var.location_short
  project                              = var.project
  vnet_cidr                            = "10.20.0.0/16"
  private_cluster_enabled              = true
  postgres_admin_password              = var.postgres_admin_password
  app_gateway_ssl_certificate_data     = var.app_gateway_ssl_certificate_data
  app_gateway_ssl_certificate_password = var.app_gateway_ssl_certificate_password
  alert_email                          = var.alert_email

  system_node_pool = {
    vm_size   = "Standard_D2s_v5"
    min_count = 1
    max_count = 3
  }

  user_node_pool = {
    vm_size   = "Standard_D4s_v5"
    min_count = 2
    max_count = 5
  }

  tags = var.tags
}

output "aks_name" {
  value = module.platform.aks_name
}

output "resource_group_name" {
  value = module.platform.resource_group_name
}

output "acr_login_server" {
  value = module.platform.acr_login_server
}

output "key_vault_name" {
  value = module.platform.key_vault_name
}
