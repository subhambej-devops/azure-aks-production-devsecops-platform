resource "azurerm_container_registry" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  data_endpoint_enabled         = true
  quarantine_policy_enabled     = true
  retention_policy_in_days      = var.retention_policy_in_days
  trust_policy_enabled          = var.trust_policy_enabled
  tags                          = var.tags

  dynamic "georeplications" {
    for_each = var.georeplication_locations
    content {
      location                = georeplications.value
      zone_redundancy_enabled = true
      tags                    = var.tags
    }
  }
}

output "id" {
  value = azurerm_container_registry.this.id
}

output "name" {
  value = azurerm_container_registry.this.name
}

output "login_server" {
  value = azurerm_container_registry.this.login_server
}
