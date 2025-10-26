##############################################
# Resource Group
##############################################

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

##############################################
# Virtual Network & Subnets
##############################################

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Subnet for Application Gateway
resource "azurerm_subnet" "appgw" {
  name                 = var.subnet_appgw_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_appgw_cidr]
}

# Subnet for AKS Cluster
resource "azurerm_subnet" "aks" {
  name                 = var.subnet_aks_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_aks_cidr]
}

# Subnet for Private Link
resource "azurerm_subnet" "privatelink" {
  name                 = var.subnet_pl_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_pl_cidr]
}

##############################################
# Azure Container Registry
##############################################

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
  tags                = var.tags
}

##############################################
# Application Gateway (Standard_v2)
##############################################

resource "azurerm_public_ip" "appgw_ip" {
  name                = "${var.prefix}-appgw-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_ip_configuration {
    name                 = "appgw-feip"
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  backend_address_pool {
    name = "dummy-bep"
  }

  backend_http_settings {
    name                  = "dummy-setting"
    cookie_based_affinity = "Disabled"
    port                  = 65535
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "dummy-listener"
    frontend_ip_configuration_name = "appgw-feip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "dummy-rule"
    rule_type                  = "Basic"
    http_listener_name         = "dummy-listener"
    backend_address_pool_name  = "dummy-bep"
    backend_http_settings_name = "dummy-setting"
    priority                   = 100
  }

  tags = var.tags
}

##############################################
# AKS Cluster with AGIC
##############################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-aks"
  tags                = var.tags

  default_node_pool {
    name            = "sysnp"
    vm_size         = "Standard_A2_v2"
    vnet_subnet_id  = azurerm_subnet.aks.id
    auto_scaling_enabled = true
    min_count       = 1
    max_count       = 3
    temporary_name_for_rotation = "temp1sysnp"
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "usernp" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_vm_size
  vnet_subnet_id        = azurerm_subnet.aks.id
  mode                  = "User"
  auto_scaling_enabled  = true
  min_count             = 1
  max_count             = 3
  node_labels = {
    "workload" = "general"
  }
  tags = var.tags
}

# Role assignment AKS -> ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Role assignment AKS -> AppGW (for AGIC)
resource "azurerm_role_assignment" "agic_role" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_application_gateway.appgw.id
}

##############################################
# Azure SQL Server + Database + Private Endpoint
##############################################

resource "azurerm_mssql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name 
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  tags                          = var.tags
}

resource "azurerm_mssql_database" "sqldb" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
  tags      = var.tags
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "sqlzone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name           
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sqlzone_link" {
  name                  = "${var.prefix}-sql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.sqlzone.name
  resource_group_name   = var.rg_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Private Endpoint for SQL
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.prefix}-sql-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.privatelink.id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns-zg"
    private_dns_zone_ids = [azurerm_private_dns_zone.sqlzone.id]
  }
}