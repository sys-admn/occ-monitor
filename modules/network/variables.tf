variable "virtual_networks" {
  description = "List of virtual networks to monitor"
  type = list(object({
    name           = string
    resource_group = string
  }))
}

variable "nat_gateways" {
  description = "List of NAT gateways to monitor"
  type = list(object({
    name           = string
    resource_group = string
  }))
  default = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "action_group_id" {
  description = "Central action group ID"
  type        = string
}