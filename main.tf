# Log Analytics Workspace centralisé
data "azurerm_log_analytics_workspace" "central" {
  name                = "data-appinsights-frc-log-1-${var.env_suffix}"
  resource_group_name = "rg-data-shared-frc-${var.env_suffix}"
}

# Storage Accounts Monitoring
module "storage_monitoring" {
  source = "./modules/storage"
  
  storage_accounts = concat(
    [
      { name = "datafrontpbifrcst1${var.env_suffix}", resource_group = "rg-data-frontpbi-frc-${var.env_suffix}" },
      { name = "datafrontpbifrcstbs1${var.env_suffix}", resource_group = "rg-data-frontpbi-frc-${var.env_suffix}" },
      { name = "datafrontpbifrcstwsd${var.env_suffix == "d" ? "" : var.env_suffix}", resource_group = "rg-data-frontpbi-frc-${var.env_suffix}" },
      { name = "dataintegfrcst1${var.env_suffix}", resource_group = "rg-data-integ-frc-${var.env_suffix}" },
      { name = "dataintegfrcstws${var.env_suffix}", resource_group = "rg-data-integ-frc-${var.env_suffix}" },
      { name = "datapbifrcstwsd${var.env_suffix == "d" ? "" : var.env_suffix}", resource_group = "rg-data-pbi-frc-${var.env_suffix}" },
      { name = "datasharedfrcstwsd${var.env_suffix == "d" ? "" : var.env_suffix}", resource_group = "rg-data-shared-frc-${var.env_suffix}" }
    ],
    var.env_suffix == "p" ? [
      { name = "datagenfilefrcstbs1p", resource_group = "rg-data-genfile-frc-p" },
      { name = "datagenfilefrcstwsp", resource_group = "rg-data-genfile-frc-p" }
    ] : []
  )
  
  activity_log_alerts = {
    container_created = {
      name            = "ala-put-blob-container"
      operation_name  = "Microsoft.Storage/storageAccounts/blobServices/containers/write"
      description     = "Alerte: Put blob container"
      localized_value = "Put blob container"
    },
    container_deleted = {
      name            = "ala-delete-blob-container"
      operation_name  = "Microsoft.Storage/storageAccounts/blobServices/containers/delete"
      description     = "Alerte: Delete blob container"
      localized_value = "Delete blob container"
    }
  }
  
  environment = var.environment
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
  retention_days = 93
  action_group_id = azurerm_monitor_action_group.central.id
}

# Virtual Machines Monitoring
module "vm_monitoring" {
  source = "./modules/vm"
  
  virtual_machines = [
    { name = "data-gw-frc-vm-01-${var.env_suffix}", resource_group = "rg-data-gw-frc-${var.env_suffix}" }
  ]
  
  environment = var.environment
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
  action_group_id = azurerm_monitor_action_group.central.id
}

# Azure Functions et Static Web Apps Monitoring
module "app_services_monitoring" {
  source = "./modules/app-services"
  
  function_apps = concat(
    [{ name = "data-frontpbi-frc-func-1-${var.env_suffix}", resource_group = "rg-data-frontpbi-frc-${var.env_suffix}" }],
    var.env_suffix == "p" ? [{ name = "data-genfile-frc-func-1-${var.env_suffix}", resource_group = "rg-data-genfile-frc-${var.env_suffix}" }] : []
  )
  
  static_web_apps = [
    { name = "data-frontpbi-frc-stapp-1-${var.env_suffix}", resource_group = "rg-data-frontpbi-frc-${var.env_suffix}" }
  ]
  
  app_service_plans = [
    { name = "data-pbi-frc-sp-1-${var.env_suffix}", resource_group = "rg-data-pbi-frc-${var.env_suffix}" }
  ]
  
  environment = var.environment
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
  action_group_id = azurerm_monitor_action_group.central.id
}

# Network Monitoring
module "network_monitoring" {
  source = "./modules/network"
  
  virtual_networks = [
    { name = "data-frc-vnet-${var.env_suffix}", resource_group = "rg-data-net-frc-${var.env_suffix}" }
  ]
  
  nat_gateways = [
    { name = "data-gw-frc-ng-01-${var.env_suffix}", resource_group = "rg-data-net-frc-${var.env_suffix}" }
  ]
  
  environment = var.environment
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
  action_group_id = azurerm_monitor_action_group.central.id
}

# Key Vault Monitoring
/*
module "keyvault_monitoring" {
  source = "./modules/keyvault"
  
  key_vaults = [
    { name = var.env_suffix == "d" ? "data-cf-kv-${var.env_suffix}" : "data-shared-frc-kv-1-${var.env_suffix}", resource_group = var.env_suffix == "d" ? "rg-data-cf-${var.env_suffix}" : "rg-data-shared-frc-${var.env_suffix}" }
  ]
  
  environment = var.environment
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
  action_group_id = azurerm_monitor_action_group.central.id
}*/

module "dashboard_monitoring" {
  source = "./modules/dashboard"
  
  environment = var.environment
  resource_group_name = "rg-data-shared-frc-${var.env_suffix}"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
}

# File Reception Monitoring
module "flux_monitoring" {
  source = "./modules/flux"
  
  environment = var.environment
  resource_group_name = "rg-data-integ-frc-${var.env_suffix}"
  storage_account_id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-data-integ-frc-${var.env_suffix}/providers/Microsoft.Storage/storageAccounts/dataintegfrcst1${var.env_suffix}"
  storage_account_name = "dataintegfrcst1${var.env_suffix}"
  expected_file_count = 0
  action_group_id = azurerm_monitor_action_group.central.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
}

