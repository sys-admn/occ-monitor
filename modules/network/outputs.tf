output "virtual_network_ids" {
  description = "List of Virtual Network resource IDs"
  value       = [for vnet in data.azurerm_virtual_network.vnet : vnet.id]
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway resource IDs"
  value       = [for ng in data.azurerm_nat_gateway.nat : ng.id]
}

output "alert_ids" {
  description = "List of Network alert resource IDs"
  value       = [for alert in azurerm_monitor_metric_alert.nat_datapath_availability : alert.id]
}