output "resource_group_name" {
  value = module.resource_group.name
}

output "aks_name" {
  value = module.aks.name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "workload_identity_client_id" {
  value = module.workload_identity.client_id
}

output "application_gateway_public_ip" {
  value = module.application_gateway.public_ip_address
}

