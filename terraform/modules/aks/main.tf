resource "azurerm_kubernetes_cluster" "this" {
  name                              = "${var.name_prefix}-aks"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = "${var.name_prefix}-aks"
  private_cluster_enabled           = var.private_cluster_enabled
  role_based_access_control_enabled = true
  azure_policy_enabled              = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  local_account_disabled            = true
  sku_tier                          = var.sku_tier
  automatic_upgrade_channel         = "stable"
  disk_encryption_set_id            = var.disk_encryption_set_id
  tags                              = var.tags

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_pool.vm_size
    vnet_subnet_id               = var.subnet_id
    zones                        = var.zones
    auto_scaling_enabled         = true
    min_count                    = var.system_node_pool.min_count
    max_count                    = var.system_node_pool.max_count
    max_pods                     = 50
    os_disk_size_gb              = 64
    os_disk_type                 = "Ephemeral"
    host_encryption_enabled      = true
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "tempsys"
    node_labels = {
      pool = "system"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  ingress_application_gateway {
    gateway_id = var.application_gateway_id
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                    = "user"
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.this.id
  vm_size                 = var.user_node_pool.vm_size
  vnet_subnet_id          = var.subnet_id
  zones                   = var.zones
  auto_scaling_enabled    = true
  min_count               = var.user_node_pool.min_count
  max_count               = var.user_node_pool.max_count
  max_pods                = 50
  os_disk_size_gb         = 64
  os_disk_type            = "Ephemeral"
  host_encryption_enabled = true
  mode                    = "User"

  node_labels = {
    pool = "user"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
