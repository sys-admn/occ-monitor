output "alert_id" {
  description = "Unified monitoring alert ID"
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.unified_monitoring_alert.id
}

output "alert_name" {
  description = "Unified monitoring alert name"
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.unified_monitoring_alert.name
}