variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "project" {
  type    = string
  default = "aks-devsecops"
}

variable "location_short" {
  type    = string
  default = "eus"
}

variable "vnet_cidr" {
  type = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "system_node_pool" {
  type = object({
    vm_size   = string
    min_count = number
    max_count = number
  })
}

variable "user_node_pool" {
  type = object({
    vm_size   = string
    min_count = number
    max_count = number
  })
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "app_gateway_ssl_certificate_data" {
  type      = string
  sensitive = true
}

variable "app_gateway_ssl_certificate_password" {
  type      = string
  sensitive = true
}

variable "alert_email" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
