##############################################
# Providers Configuration
##############################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.49"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "tfstategrp3"
  #   container_name       = "tfstate"
  #   key                  = "infra-group3.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = "4421688c-0a8d-4588-8dd0-338c5271d0af" 
}