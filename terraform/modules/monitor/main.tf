resource "azurerm_monitor_action_group" "this" {
  name                = "${var.name_prefix}-ag"
  resource_group_name = var.resource_group_name
  short_name          = "aksops"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email == "" ? [] : [var.alert_email]
    content {
      name          = "platform-email"
      email_address = email_receiver.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "node_cpu" {
  name                = "${var.name_prefix}-node-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "AKS node CPU exceeded 80 percent."
  frequency           = "PT5M"
  window_size         = "PT15M"
  severity            = 2
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_metric_alert" "node_memory" {
  name                = "${var.name_prefix}-node-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "AKS node memory exceeded 85 percent."
  frequency           = "PT5M"
  window_size         = "PT15M"
  severity            = 2
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

output "action_group_id" {
  value = azurerm_monitor_action_group.this.id
}

