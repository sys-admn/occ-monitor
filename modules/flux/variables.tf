variable "environment" {
  description = "Environment suffix"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "storage_account_id" {
  description = "Storage account resource ID"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
}

variable "expected_file_count" {
  description = "Expected minimum number of files"
  type        = number
  default     = 0
}

variable "action_group_id" {
  description = "Action group ID for alerts"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for log search alert"
  type        = string
}