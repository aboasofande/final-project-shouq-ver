##############################################
# General Variables
##############################################

variable "prefix" {
  description = "Project prefix used for naming resources"
  type        = string
  default     = "grp3"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "southeastasia"
}

variable "rg_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "rg-grp3-aks"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    project = "3tier-aks"
    env     = "dev"
    team    = "group3"
  }
}

##############################################
# Network
##############################################

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "vnet-grp3"
}

variable "vnet_cidr" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.50.0.0/16"
}

# ===== Subnets =====
# Application Gateway Subnet
variable "subnet_appgw_name" {
  description = "Subnet for Application Gateway"
  type        = string
  default     = "snet-appgw"
}

variable "subnet_appgw_cidr" {
  description = "CIDR block for Application Gateway subnet"
  type        = string
  default     = "10.50.5.0/24"
}

# AKS Subnet
variable "subnet_aks_name" {
  description = "Subnet for AKS Cluster"
  type        = string
  default     = "snet-aks"
}

variable "subnet_aks_cidr" {
  description = "CIDR block for AKS subnet"
  type        = string
  default     = "10.50.1.0/24"
}

# Private Link Subnet
variable "subnet_pl_name" {
  description = "Subnet for Private Link"
  type        = string
  default     = "snet-privatelink"
}

variable "subnet_pl_cidr" {
  description = "CIDR block for Private Link subnet"
  type        = string
  default     = "10.50.2.0/24"
}

##############################################
# ACR
##############################################

variable "acr_name" {
  description = "Azure Container Registry name (must be unique globally)"
  type        = string
  default     = "grp3acr"
}

##############################################
# AKS
##############################################

variable "aks_name" {
  description = "Azure Kubernetes Service cluster name"
  type        = string
  default     = "aks-grp3"
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

##############################################
# Azure SQL
##############################################

variable "sql_server_name" {
  description = "SQL Server name"
  type        = string
  default     = "grp3sqlsrv"
}

variable "sql_db_name" {
  description = "Database name"
  type        = string
  default     = "grp3db"
}

variable "sql_admin_login" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Administrator password for SQL Server"
  type        = string
  default     = "StrongP@ssw0rd!!"
  sensitive   = true
}