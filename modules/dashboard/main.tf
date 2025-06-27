resource "azurerm_portal_dashboard" "monitoring_dashboard" {
  name                = "dashboard-monitoring-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "alertsmanagementresources | where properties.essentials.startDateTime > ago(24h) | extend StartDateTime = todatetime(properties.essentials.startDateTime) | project AlertName = name, Severity = case(tostring(properties.essentials.severity) == \"Sev0\", \"Critical\", tostring(properties.essentials.severity) == \"Sev1\", \"Error\", tostring(properties.essentials.severity) == \"Sev2\", \"Warning\", \"No Alerts\"), State = case(tostring(properties.essentials.alertState) == \"New\", \"New\", tostring(properties.essentials.alertState) == \"Acknowledged\", \"Acknowledged\", \"Closed\"), Resource = extract(@\"([^/]+)$\", 1, tostring(properties.essentials.targetResource)), StartTime = format_datetime(datetime_utc_to_local(StartDateTime, \"Europe/Paris\"), \"dd/MM HH:mm\"), StartDateTime | order by StartDateTime desc | take 20"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "1" = {
            position = { x = 6, y = 0, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.STORAGE\" | where MetricName == \"Availability\" | where TimeGenerated >= ago(24h) | extend StorageAccountName = tostring(split(Resource, \"/\")[8]) | summarize arg_max(TimeGenerated, Average), AvgAvailability = avg(Average) by _ResourceId, ResourceGroup, StorageAccountName | project ResourceGroup, StorageAccount = StorageAccountName, CurrentAvailability = round(Average, 2), AvgAvailability = round(AvgAvailability, 2) | sort by CurrentAvailability asc | render columnchart with (xcolumn=AvgAvailability, ycolumns=CurrentAvailability, series=ResourceGroup)"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "2" = {
            position = { x = 0, y = 4, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.COMPUTE\" | where ResourceType == \"VIRTUALMACHINES\" | where MetricName == \"Percentage CPU\" | where Resource contains \"${var.environment}\" | where TimeGenerated >= ago(24h) | summarize AvgCPU = avg(Average), MaxCPU = max(Average) by bin(TimeGenerated, 1h), Resource, ResourceGroup | project TimeGenerated = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), VM = Resource, ResourceGroup, AvgCPU = round(AvgCPU, 2), MaxCPU = round(MaxCPU, 2) | render columnchart with (xcolumn=TimeGenerated, ycolumns=AvgCPU, series=ResourceGroup)"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "3" = {
            position = { x = 6, y = 4, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "Usage | where DataType in ('AzureMetrics', 'FunctionAppLogs', 'AzureDiagnostics', 'StorageBlobLogs') | summarize IngestionVolumeMB=sum(Quantity) by DataType | sort by IngestionVolumeMB | project DataType, IngestionVolumeMB"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "4" = {
            position = { x = 0, y = 8, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.WEB\" | where MetricName == \"Http5xx\" | where Resource contains \"${var.environment}\" | summarize ErrorCount = sum(Total) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), FunctionApp = Resource, Errors = ErrorCount | render timechart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "5" = {
            position = { x = 6, y = 8, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.KEYVAULT\" | where MetricName == \"Availability\" | where Resource contains \"${var.environment}\" | summarize AvgAvailability = avg(Average) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), KeyVault = Resource, Availability = round(AvgAvailability, 2) | render timechart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "6" = {
            position = { x = 0, y = 12, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.NETWORK\" | where MetricName == \"ByteCount\" | where Resource contains \"${var.environment}\" | summarize TotalBytes = sum(Total) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), Network = Resource, Bytes = TotalBytes | render areachart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "7" = {
            position = { x = 6, y = 12, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.STORAGE\" | where MetricName == \"Transactions\" | where Resource contains \"${var.environment}\" | summarize TotalTransactions = sum(Total) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), Storage = Resource, Transactions = TotalTransactions | render barchart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "8" = {
            position = { x = 0, y = 16, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.COMPUTE\" | where MetricName == \"Disk Read Bytes\" | where Resource contains \"${var.environment}\" | summarize AvgDiskRead = avg(Average) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), VM = Resource, DiskRead = round(AvgDiskRead, 2) | render linechart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "9" = {
            position = { x = 6, y = 16, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.WEB\" | where MetricName == \"MemoryWorkingSet\" | where Resource contains \"${var.environment}\" | summarize AvgMemory = avg(Average) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), App = Resource, Memory = round(AvgMemory/1024/1024, 2) | render areachart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "10" = {
            position = { x = 0, y = 20, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "AzureMetrics | where ResourceProvider == \"MICROSOFT.STORAGE\" | where MetricName == \"UsedCapacity\" | where Resource contains \"${var.environment}\" | summarize AvgUsedCapacity = avg(Average) by bin(TimeGenerated, 1h), Resource | project Time = datetime_utc_to_local(TimeGenerated, \"Europe/Paris\"), Storage = Resource, UsedCapacityGB = round(AvgUsedCapacity/1024/1024/1024, 2) | render columnchart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
          "11" = {
            position = { x = 6, y = 20, rowSpan = 4, colSpan = 6 }
            metadata = {
              inputs = [{
                name = "ComponentId"
                value = var.log_analytics_workspace_id
              }, {
                name = "Query"
                value = "healthresources | where type == \"microsoft.resourcehealth/availabilitystatuses\" | where id contains \"${var.environment}\" | extend AvailabilityState = properties.availabilityState | summarize count() by AvailabilityState | project Status = case(AvailabilityState == \"Available\", \"Available\", AvailabilityState == \"Unavailable\", \"Unavailable\", \"Unknown\"), Count = count_ | render piechart"
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
          }
        }
      }
    }
  })

  tags = {
    Environment = var.environment
    Purpose     = "Monitoring Dashboard"
  }
}