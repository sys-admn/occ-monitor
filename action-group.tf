# Action Group centralisé par environnement
resource "azurerm_monitor_action_group" "central" {
  name                = "monitoring-alerts-${var.environment}"
  resource_group_name = "rg-data-shared-frc-${var.env_suffix}"
  short_name          = "ag-${var.env_suffix}"

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "alert-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = {
    Environment = var.environment
    Purpose     = "Central monitoring alerts"
  }
}