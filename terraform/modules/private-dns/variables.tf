variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "zone_names" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

