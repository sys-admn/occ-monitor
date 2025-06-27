variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "env_suffix" {
  description = "Environment suffix (d for dev, p for prod)"
  type        = string
}

variable "alert_email_addresses" {
  description = "List of email addresses for monitoring alerts"
  type        = list(string)
  default     = ["a.sall@groupeonepoint.com","cds_si_orangeconcessions@experisfrance.fr"]
}