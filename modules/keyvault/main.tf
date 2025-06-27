data "azurerm_key_vault" "kv" {
  for_each            = { for kv in var.key_vaults : kv.name => kv }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

resource "azurerm_monitor_metric_alert" "keyvault_availability" {
  for_each            = { for kv in var.key_vaults : kv.name => kv }
  name                = "${each.value.name}-availability-alert"
  resource_group_name = each.value.resource_group
  scopes              = [data.azurerm_key_vault.kv[each.key].id]
  description         = "Key Vault availability alert"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics" {
  for_each           = { for kv in var.key_vaults : kv.name => kv }
  name               = "${each.value.name}-diagnostics"
  target_resource_id = data.azurerm_key_vault.kv[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}