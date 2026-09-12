resource "azurerm_public_ip" "this" {
  name                = "${var.name_prefix}-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = "${var.name_prefix}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  zones               = var.zones
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "bootstrap-empty-pool"
  }

  ssl_certificate {
    name     = "platform-listener-cert"
    data     = var.ssl_certificate_data
    password = var.ssl_certificate_password
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }

  backend_http_settings {
    name                  = "https"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
  }

  http_listener {
    name                           = "https"
    frontend_ip_configuration_name = "public"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "platform-listener-cert"
  }

  request_routing_rule {
    name                       = "bootstrap"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "https"
    backend_address_pool_name  = "bootstrap-empty-pool"
    backend_http_settings_name = "https"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = var.waf_mode
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      ssl_certificate,
      tags["ingress-for-aks-cluster-id"],
    ]
  }
}

output "id" {
  value = azurerm_application_gateway.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}
