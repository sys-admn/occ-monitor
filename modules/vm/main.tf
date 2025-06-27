data "azurerm_virtual_machine" "vm" {
  for_each            = { for vm in var.virtual_machines : vm.name => vm }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

resource "azurerm_monitor_metric_alert" "vm_cpu" {
  for_each            = { for vm in var.virtual_machines : vm.name => vm }
  name                = "${each.value.name}-cpu-alert"
  resource_group_name = each.value.resource_group
  scopes              = [data.azurerm_virtual_machine.vm[each.key].id]
  description         = "VM CPU usage alert"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "vm_availability" {
  for_each            = { for vm in var.virtual_machines : vm.name => vm }
  name                = "${each.value.name}-availability-alert"
  resource_group_name = each.value.resource_group
  scopes              = [data.azurerm_virtual_machine.vm[each.key].id]
  description         = "VM availability alert"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  for_each           = { for vm in var.virtual_machines : vm.name => vm }
  name               = "${each.value.name}-diagnostics"
  target_resource_id = data.azurerm_virtual_machine.vm[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}