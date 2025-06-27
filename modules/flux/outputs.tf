output "alert_id" {
  description = "ID of the file reception alert"
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.file_reception_alert.id
}