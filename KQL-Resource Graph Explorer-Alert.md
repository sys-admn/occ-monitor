alertsmanagementresources
| where properties.essentials.startDateTime > ago(24h)
| extend StartDateTime = todatetime(properties.essentials.startDateTime)
| project 
    AlertName = name,
    Severity = case(
        tostring(properties.essentials.severity) == "Sev0", "Critical",
        tostring(properties.essentials.severity) == "Sev1", "Error", 
        tostring(properties.essentials.severity) == "Sev2", "Warning",
        tostring(properties.essentials.severity) == "Sev3", "Info",
        tostring(properties.essentials.severity) == "Sev4", "Verbose",
        "Unknown"
    ),
    State = case(
        tostring(properties.essentials.alertState) == "New", "New",
        tostring(properties.essentials.alertState) == "Acknowledged", "Acknowledged", 
        tostring(properties.essentials.alertState) == "Closed", "Closed",
        tostring(properties.essentials.alertState)
    ),
    Resource = extract(@"([^/]+)$", 1, tostring(properties.essentials.targetResource)),
    ResourceType = tostring(properties.essentials.targetResourceType),
    StartTime = format_datetime(datetime_utc_to_local(StartDateTime, "Europe/Paris"), "dd/MM HH:mm"),
    StartDateTime 
| order by StartDateTime desc
| take 50
