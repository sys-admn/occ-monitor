data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "storage" {
  for_each            = { for sa in var.storage_accounts : sa.name => sa }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

resource "azurerm_monitor_metric_alert" "storage_availability" {
  for_each            = { for sa in var.storage_accounts : sa.name => sa }
  name                = "${each.value.name}-availability-alert"
  resource_group_name = each.value.resource_group
  scopes              = [data.azurerm_storage_account.storage[each.key].id]
  description         = "Storage account availability alert"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  for_each           = { for sa in var.storage_accounts : sa.name => sa }
  name               = "${each.value.name}-diagnostics"
  target_resource_id = data.azurerm_storage_account.storage[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "Transaction"
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob_diagnostics" {
  for_each           = { for sa in var.storage_accounts : sa.name => sa }
  name               = "${each.value.name}-blob-diagnostics"
  target_resource_id = "${data.azurerm_storage_account.storage[each.key].id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}


resource "azurerm_monitor_activity_log_alert" "blob_activity" {
  for_each            = var.activity_log_alerts
  name                = each.value.name
  resource_group_name = "rg-data-shared-frc-${var.environment == "dev" ? "d" : "p"}"
  scopes              = [for sa in var.storage_accounts : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${sa.resource_group}/providers/Microsoft.Storage/storageAccounts/${sa.name}"]
  description         = each.value.description
  location = "francecentral"

  criteria {
    operation_name = each.value.operation_name
    category       = "Administrative"
  }

  action {
    action_group_id = var.action_group_id
  }
}
