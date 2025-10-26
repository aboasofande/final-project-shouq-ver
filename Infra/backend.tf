terraform {
  backend "azurerm" {
    resource_group_name  = "AA-rg-grp3-tfstate"
    storage_account_name = "aagrp3tfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}