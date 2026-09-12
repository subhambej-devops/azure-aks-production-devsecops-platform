variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "Premium"
}

variable "trust_policy_enabled" {
  type    = bool
  default = true
}

variable "retention_policy_in_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "georeplication_locations" {
  type    = list(string)
  default = ["westus2"]
}
