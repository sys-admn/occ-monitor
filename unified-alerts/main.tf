resource "azurerm_monitor_scheduled_query_rules_alert_v2" "unified_monitoring_alert" {
  name                = "Rootcause-Incident-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 2
  
  criteria {
    query = <<-QUERY
       let AppRequestLogs = 
          AppRequests
          | where TimeGenerated > ago(5m)
          | where Success == false or DurationMs > 5000 or ResultCode !in (200, 0)
          | project
              TimeGenerated,
              Source = "AppRequests",
              Name,
              Url,
              ResultCode = tostring(ResultCode),
              Success,
              DurationMs = toreal(DurationMs),
              OperationId,
              Message = "",
              Resource = AppRoleName;

      let AppTraceLogs = 
          AppTraces
          | where TimeGenerated > ago(5m)
          | where SeverityLevel >= 3 or Message has "Exception"
          | project
              TimeGenerated,
              Source = "Traces",
              Name = "",
              Url = "",
              ResultCode = "",
              Success = bool(null),
              DurationMs = real(null),
              OperationId,
              Message,
              Resource = AppRoleName;

      let MetricsAlerts = 
          AzureMetrics
          | where TimeGenerated > ago(5m)
          | where (MetricName in ('MemoryPercentage', 'CpuPercentage') and Average >= 80) or (MetricName has 'Availability' and Average < 100)
          | project
              TimeGenerated,
              Source = case(
                  MetricName == "CpuPercentage", "CpuMetrics",
                  MetricName == "MemoryPercentage", "MemoryMetrics",
                  MetricName has "Availability", "AvailabilityMetrics",
                  "UnknownMetrics"
              ),
              Name = case(
                  MetricName == "CpuPercentage", "High CPU Usage",
                  MetricName == "MemoryPercentage", "High Memory Usage",
                  MetricName has "Availability", "Low Availability",
                  "Unknown Issue"
              ),
              Url = "",
              ResultCode = "",
              Success = bool(null),
              DurationMs = real(null),
              OperationId = "",
              Message = case(
                  MetricName == "CpuPercentage", strcat("CPU: ", round(Average, 2), "%"),
                  MetricName == "MemoryPercentage", strcat("Memory: ", round(Average, 2), "%"),
                  MetricName has "Availability", strcat("Availability: ", round(Average, 2), "%"),
                  "Unknown metric"
              ),
              Resource;

      let StorageActivity = 
          StorageBlobLogs
          | where TimeGenerated > ago(5m)
          | where OperationName in ("PutBlob")
          | extend 
              ContainerName = extract(@"/([^/]+)/", 1, Uri),
              FileName = extract(@"/([^/?]+)(?:\?.*)?$", 1, Uri)
          | project
              TimeGenerated,
              Source = "TransactionMetrics",
              Name = "Storage Activity",
              Url = Uri,
              ResultCode = StatusCode,
              Success = bool(null),
              DurationMs = real(null),
              OperationId = "",
              Message = strcat("File: ", FileName, " in container: ", ContainerName, " (", OperationName, ")"),
              Resource = AccountName;

      AppRequestLogs
      | union AppTraceLogs
      | union MetricsAlerts
      | union StorageActivity
      | extend 
          Severity = case(
              Source in ("CpuMetrics", "MemoryMetrics", "AvailabilityMetrics"), "Critical",
              Source == "TransactionMetrics", "Info",
              Source == "AppRequests" and Success == false, "Error",
              Source == "AppRequests" and DurationMs > 5000, "Warning",
              Source == "Traces", "Error",
              "Info"
          ),
          ProblemType = case(
              Source == "CpuMetrics", "App Service Plan CPU Performance",
              Source == "MemoryMetrics", "App Service Memory Performance",
              Source == "AvailabilityMetrics", "Availability",
              Source == "TransactionMetrics", "Storage Activity",
              Source == "AppRequests" and Success == false, "HTTP Error",
              Source == "AppRequests" and DurationMs > 5000, "Slow Response",
              Source == "Traces", "Application Error",
              "Unknown"
          )
      | summarize 
          LastEventTime = max(TimeGenerated),
          EventCount = count(),
          Resources = make_set(Resource),
          Messages = make_set(Message)
      by ProblemType, Severity
      | project 
          ProblemType,
          Severity,
          LastEventTime,
          EventCount,
          Resources = tostring(Resources),
          Messages = tostring(Messages)
      | order by LastEventTime desc
    QUERY
    
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }
  
  action {
    action_groups = [var.action_group_id]
    custom_properties = {
      "ProblemType" = "{{table_result[0][0]}}"
      "Severity" = "{{table_result[0][1]}}"
      "LastEventTime" = "{{table_result[0][2]}}"
      "EventCount" = "{{table_result[0][3]}}"
      "Resources" = "{{table_result[0][4]}}"
      "Messages" = "{{table_result[0][5]}}"
    }
  }
  
  tags = {
    Environment = var.environment
    Purpose     = "Unified Monitoring"
  }
}