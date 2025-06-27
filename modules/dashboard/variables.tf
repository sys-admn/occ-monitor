variable "environment" {
  description = "Environment suffix (d for dev, p for prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the dashboard"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  type        = string
}