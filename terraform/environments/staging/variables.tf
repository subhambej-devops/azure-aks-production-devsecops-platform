variable "location" {
  type    = string
  default = "eastus"
}

variable "location_short" {
  type    = string
  default = "eus"
}

variable "project" {
  type    = string
  default = "aks-devsecops"
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
  type = map(string)
  default = {
    owner       = "sujoy-halder"
    cost_center = "portfolio"
  }
}
