output "vm_ids" {
  description = "List of Virtual Machine resource IDs"
  value       = [for vm in data.azurerm_virtual_machine.vm : vm.id]
}

output "alert_ids" {
  description = "List of VM alert resource IDs"
  value       = [for alert in azurerm_monitor_metric_alert.vm_cpu : alert.id]
}