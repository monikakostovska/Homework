terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  backend "azurerm" { }
}

data "azurerm_subscription" "current" {
}

provider "azurerm" {
  features {}
}

locals {
  base_name         = "${var.my_name}-${var.environment}"
  network_base_name = "${local.base_name}-ntwrk"
}

resource "azurerm_resource_group" "az-rg1" {
  name     = "${local.network_base_name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "VNet1" {
  name                = "${local.network_base_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az-rg1.location
  resource_group_name = azurerm_resource_group.az-rg1.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${azurerm_virtual_network.VNet1.name}-vms-snet"
  resource_group_name  = azurerm_resource_group.az-rg1.name
  virtual_network_name = azurerm_virtual_network.VNet1.name
  address_prefixes     = ["10.0.2.0/24"]
}


#module for the VM
module "vm" {
  source    = "./vm_module"
  base_name = local.base_name
  location  = var.location
  vms_subnet_id = azurerm_subnet.general_network_vms.subnet_id
  public_ip = var.public_ip
  password = var.password
}

