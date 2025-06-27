data "azurerm_resource_group" "flux_rg" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "monitored_storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "file_reception_alert" {
  name                = "flux-file-received-${var.environment}"
  resource_group_name = data.azurerm_resource_group.flux_rg.name
  location            = var.location
  
  evaluation_frequency = "PT1M"
  window_duration      = "PT5M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 3
  
  criteria {
    query                   = <<-QUERY
      StorageBlobLogs
      | where TimeGenerated > ago(5m)
      | where AccountName == "${var.storage_account_name}"
      | where OperationName == "PutBlob" or OperationName == "PutBlockList"
      | where toint(StatusCode) < 300
      | extend FileName = extract(@"([^/?]+)(?:\?.*)?$", 1, Uri)
      | project TimeGenerated, FileName, Uri
      | summarize FileCount = count(), FileNames = make_list(FileName), FilePaths = make_list(Uri) by bin(TimeGenerated, 1m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }
  
  action {
    action_groups = [var.action_group_id]
    custom_properties = {
      "FileCount" = "{{table_result[0][1]}}"
      "FileNames" = "{{table_result[0][2]}}"
      "FilePaths" = "{{table_result[0][3]}}"
    }
  }
  
  tags = {
    Environment = var.environment
    Purpose     = "File Reception Monitoring"
  }
}