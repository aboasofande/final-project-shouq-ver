##############################################
# General Information
##############################################

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "Deployment location"
  value       = var.location
}

##############################################
# Networking
##############################################

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.vnet.name
}

output "subnets" {
  description = "All subnet names"
  value = [
    azurerm_subnet.appgw.name,
    azurerm_subnet.aks.name,
    azurerm_subnet.privatelink.name
  ]
}

##############################################
# Application Gateway
##############################################

output "appgw_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw_ip.ip_address
}

output "appgw_name" {
  description = "Application Gateway name"
  value       = azurerm_application_gateway.appgw.name
}

##############################################
# Azure Kubernetes Service (AKS)
##############################################

output "aks_name" {
  description = "AKS Cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_oidc_issuer" {
  description = "AKS OIDC issuer URL (for future GitHub OIDC use)"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

##############################################
# Azure Container Registry (ACR)
##############################################

output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.acr.login_server
}

##############################################
# Azure SQL
##############################################

output "sql_fqdn" {
  description = "Fully Qualified Domain Name (FQDN) of SQL Server"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_private_endpoint_ip" {
  description = "Private IP of the SQL Private Endpoint"
  value       = azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
}

##############################################
# Monitoring
##############################################

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.law.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.law.id
}