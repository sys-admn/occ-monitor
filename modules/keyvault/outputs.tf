output "key_vault_ids" {
  description = "List of Key Vault resource IDs"
  value       = [for kv in data.azurerm_key_vault.kv : kv.id]
}

output "alert_ids" {
  description = "List of Key Vault alert resource IDs"
  value       = [for alert in azurerm_monitor_metric_alert.keyvault_availability : alert.id]
}