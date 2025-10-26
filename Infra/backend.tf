terraform {
  backend "azurerm" {
    resource_group_name  = "rg-grp3-tf"
    storage_account_name = "grp3tfstate"
    container_name       = "tfstate"
    key                  = "infra/burgerapp.tfstate"
  }
}