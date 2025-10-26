##############################################
# Log Analytics Workspace
##############################################

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

##############################################
# Diagnostic Settings
##############################################

# AKS Diagnostics
resource "azurerm_monitor_diagnostic_setting" "aks_diagnostics" {
  name                       = "${var.prefix}-aks-diag"
  target_resource_id          = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.law.id

  enabled_log { category = "kube-apiserver" }
  enabled_log { category = "kube-controller-manager" }
  enabled_log { category = "cluster-autoscaler" }
  metric       { category = "AllMetrics" }

  depends_on = [azurerm_log_analytics_workspace.law]
}

# Application Gateway Diagnostics
resource "azurerm_monitor_diagnostic_setting" "appgw_diagnostics" {
  name                       = "${var.prefix}-appgw-diag"
  target_resource_id          = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.law.id

  enabled_log { category = "ApplicationGatewayAccessLog" }
  enabled_log { category = "ApplicationGatewayPerformanceLog" }
  enabled_log { category = "ApplicationGatewayFirewallLog" }
  metric       { category = "AllMetrics" }

  depends_on = [azurerm_log_analytics_workspace.law]
}



##############################################
# Action Group (for Alerts)
##############################################

resource "azurerm_monitor_action_group" "devops_alerts" {
  name                = "${var.prefix}-alert-group"
  resource_group_name = azurerm_resource_group.rg.name        
  short_name          = "grp3ag"

  email_receiver {
    name          = "admin-email"
    email_address = "shouqaldous5@gmail.com"
  }

  tags = var.tags
}

##############################################
# Metric Alert (AKS CPU Usage)
##############################################
