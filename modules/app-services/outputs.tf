output "function_app_ids" {
  description = "List of Function App resource IDs"
  value       = [for fa in data.azurerm_linux_function_app.func : fa.id]
}

output "static_web_app_ids" {
  description = "List of Static Web App resource IDs"
  value       = [for swa in data.azurerm_static_web_app.static : swa.id]
}

output "app_service_plan_ids" {
  description = "List of App Service Plan resource IDs"
  value       = [for asp in data.azurerm_service_plan.asp : asp.id]
}

output "alert_ids" {
  description = "List of App Services alert resource IDs"
  value       = [for alert in azurerm_monitor_metric_alert.function_alerts : alert.id]
}