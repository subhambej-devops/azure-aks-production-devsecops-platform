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

variable "capacity" {
  type    = number
  default = 2
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "ssl_certificate_data" {
  type      = string
  sensitive = true
}

variable "ssl_certificate_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
