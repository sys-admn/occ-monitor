data "azurerm_linux_function_app" "func" {
  for_each            = { for fa in var.function_apps : fa.name => fa }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

data "azurerm_static_web_app" "static" {
  for_each            = { for sa in var.static_web_apps : sa.name => sa }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

data "azurerm_service_plan" "asp" {
  for_each            = { for asp in var.app_service_plans : asp.name => asp }
  name                = each.value.name
  resource_group_name = each.value.resource_group
}

# Function App alerts configuration
locals {
  function_alerts = {
    http_errors = {
      name             = "http-errors-alert"
      description      = "Alert when Function App has HTTP 5xx errors"
      severity         = 1
      frequency        = "PT5M"
      window_size      = "PT5M"
      metric_namespace = "Microsoft.Web/sites"
      metric_name      = "Http5xx"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 5
    }
    response_time = {
      name             = "response-time-alert"
      description      = "Alert when Function App response time is high"
      severity         = 2
      frequency        = "PT15M"
      window_size      = "PT30M"
      metric_namespace = "Microsoft.Web/sites"
      metric_name      = "HttpResponseTime"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 5000
    }
    availability = {
      name             = "func-availability-alert"
      description      = "Alert when Function App has no requests (stopped)"
      severity         = 1
      frequency        = "PT15M"
      window_size      = "PT30M"
      metric_namespace = "Microsoft.Web/sites"
      metric_name      = "Requests"
      aggregation      = "Total"
      operator         = "LessThan"
      threshold        = 1
    }
  }
}

resource "azurerm_monitor_metric_alert" "function_alerts" {
for_each = {
    for combo in flatten([
      for fa_key, fa in { for fa in var.function_apps : fa.name => fa } : [
        for alert_key, alert in local.function_alerts : {
          key         = "${fa_key}-${alert_key}"
          fa_key      = fa_key
          alert_key   = alert_key
          fa          = fa
          alert       = alert
        }
      ]
    ]) : combo.key => combo
  }

  name                = "${each.value.fa.name}-${each.value.alert.name}"
  resource_group_name = each.value.fa.resource_group
  scopes              = [data.azurerm_linux_function_app.func[each.value.fa_key].id]
  description         = each.value.alert.description
  severity            = each.value.alert.severity
  frequency           = each.value.alert.frequency
  window_size         = each.value.alert.window_size

criteria {
   metric_namespace = each.value.alert.metric_namespace
   metric_name      = each.value.alert.metric_name
   aggregation      = each.value.alert.aggregation
   operator         = each.value.alert.operator
   threshold        = each.value.alert.threshold
  }

action {
   action_group_id = var.action_group_id
  }
 }

resource "azurerm_monitor_diagnostic_setting" "function_diagnostics" {
  for_each           = { for fa in var.function_apps : fa.name => fa }
  name               = "${each.value.name}-diagnostics"
  target_resource_id = data.azurerm_linux_function_app.func[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FunctionAppLogs"
  }

  enabled_log {
    category = "AppServiceAuthenticationLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "app_service_plan_diagnostics" {
  for_each           = { for asp in var.app_service_plans : asp.name => asp }
  name               = "${each.value.name}-diagnostics"
  target_resource_id = data.azurerm_service_plan.asp[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}