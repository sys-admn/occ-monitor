variable "storage_accounts" {
  description = "List of storage accounts to monitor"
  type = list(object({
    name           = string
    resource_group = string
  }))
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 93
}

variable "action_group_id" {
  description = "Central action group ID"
  type        = string
}

variable "activity_log_alerts" {
  description = "Activity log alerts configuration for blob services"
  type = map(object({
    name            = string
    operation_name  = string
    description     = string
    localized_value = string
  }))
  default = {}
}