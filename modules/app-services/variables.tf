variable "function_apps" {
  description = "List of function apps to monitor"
  type = list(object({
    name           = string
    resource_group = string
  }))
  default = []
}

variable "static_web_apps" {
  description = "List of static web apps to monitor"
  type = list(object({
    name           = string
    resource_group = string
  }))
  default = []
}

variable "app_service_plans" {
  description = "List of app service plans to monitor"
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