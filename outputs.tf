output "log_analytics_workspace_id" {
  description = "Central Log Analytics Workspace ID"
  value       = data.azurerm_log_analytics_workspace.central.id
}

output "central_action_group_id" {
  description = "Central Action Group ID"
  value       = azurerm_monitor_action_group.central.id
}

output "storage_monitoring" {
  description = "Storage monitoring outputs"
  value = {
    storage_account_ids = module.storage_monitoring.storage_account_ids
    alert_ids          = module.storage_monitoring.alert_ids
  }
}

output "vm_monitoring" {
  description = "VM monitoring outputs"
  value = {
    vm_ids    = module.vm_monitoring.vm_ids
    alert_ids = module.vm_monitoring.alert_ids
  }
}

output "app_services_monitoring" {
  description = "App Services monitoring outputs"
  value = {
    function_app_ids     = module.app_services_monitoring.function_app_ids
    static_web_app_ids   = module.app_services_monitoring.static_web_app_ids
    app_service_plan_ids = module.app_services_monitoring.app_service_plan_ids
    alert_ids           = module.app_services_monitoring.alert_ids
  }
}

output "network_monitoring" {
  description = "Network monitoring outputs"
  value = {
    virtual_network_ids = module.network_monitoring.virtual_network_ids
    nat_gateway_ids     = module.network_monitoring.nat_gateway_ids
    alert_ids          = module.network_monitoring.alert_ids
  }
}

output "keyvault_monitoring" {
  description = "Key Vault monitoring outputs"
  value = {
    key_vault_ids = module.keyvault_monitoring.key_vault_ids
    alert_ids     = module.keyvault_monitoring.alert_ids
  }
}