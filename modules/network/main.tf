data "azurerm_virtual_network" "vnet" {
  for_each            = { for vn in var.virtual_networks : vn.name => vn }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

data "azurerm_nat_gateway" "nat" {
  for_each            = { for ng in var.nat_gateways : ng.name => ng }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

resource "azurerm_monitor_metric_alert" "nat_datapath_availability" {
  for_each            = { for ng in var.nat_gateways : ng.name => ng }
  name                = "${each.value.name}-datapath-availability-alert"
  resource_group_name = each.value.resource_group
  scopes              = [data.azurerm_nat_gateway.nat[each.key].id]
  description         = "Alert when NAT Gateway datapath availability degrades"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Network/natGateways"
    metric_name      = "DatapathAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_diagnostic_setting" "vnet_diagnostics" {
  for_each           = { for vn in var.virtual_networks : vn.name => vn }
  name               = "${each.value.name}-diagnostics"
  target_resource_id = data.azurerm_virtual_network.vnet[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}