terraform {
  backend "azurerm" {
    resource_group_name  = "rg-data-cf-d"
    storage_account_name = "datacfstd"
    container_name       = "tfstates"
    key                  = "data.development.azure_monitor.tfstate"
  }
}