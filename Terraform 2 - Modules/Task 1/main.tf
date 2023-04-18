
terraform {
  backend "azurerm" {
   # resource_group_name  = "pv84efg2-rg"
   # storage_account_name = "pv84efg2sa"
   # container_name       = "tfstate"
   # key                  = "monika.tfstate"
  }
}


provider "azurerm" {
  features {}    
}

data "azurerm_subscription" "current" {
}

