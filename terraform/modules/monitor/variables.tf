variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "aks_cluster_id" {
  type = string
}

variable "alert_email" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

