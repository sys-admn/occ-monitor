output "storage_account_ids" {
  description = "List of storage account resource IDs"
  value       = [for sa in data.azurerm_storage_account.storage : sa.id]
}

output "alert_ids" {
  description = "List of storage alert resource IDs"
  value       = [for alert in azurerm_monitor_metric_alert.storage_availability : alert.id]
}