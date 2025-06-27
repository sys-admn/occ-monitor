output "dashboard_id" {
  description = "ID of the created dashboard"
  value       = azurerm_portal_dashboard.monitoring_dashboard.id
}

output "dashboard_name" {
  description = "Name of the created dashboard"
  value       = azurerm_portal_dashboard.monitoring_dashboard.name
}