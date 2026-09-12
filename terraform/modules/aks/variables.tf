variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "application_gateway_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "disk_encryption_set_id" {
  type = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "sku_tier" {
  type    = string
  default = "Standard"
}

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
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

variable "tags" {
  type    = map(string)
  default = {}
}
