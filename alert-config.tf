# Alert configuration centralisée
locals {
  alert_frequencies = {
    standard = "PT5M"
    long     = "PT15M"
    extended = "PT30M"
  }
  
  alert_windows = {
    short  = "PT5M"
    medium = "PT15M"
    long   = "PT30M"
  }
  
  alert_thresholds = {
    storage_availability         = 99
    function_response_time      = 5000
    function_http_errors        = 5
    vm_cpu_percentage          = 80
    keyvault_availability      = 99
    nat_datapath_availability  = 99
    asp_cpu_percentage         = 80
    asp_memory_percentage      = 80
  }
}