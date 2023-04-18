#terraform {
#  required_providers {
#    azurerm = {
#      source = "hashicorp/azurerm"
#      version = "3.52.0"
#    }
#  }
#}

#provider "azurerm" {
#  features {
  #}
 #   
#}

locals {
  vm_name = "${var.base_name}-vm"
}

resource "azure_resource_group" "vm" {
  name = "${local.vm_name}-rg"
  location = var.location
  }

resource "azurerm_public_ip" "vm" {
  name = "${local.vm_name}-pip" 
  location = azure_resource_group.vm.location
  resource_group_name = "azurerm_resource_group.vm_name"
  allocation_method = "Static"    

 # tags = {
 #  environment = "dev"
 # }
}

resource "azurerm_network_interface" "vm" {
  name = "${local.vm_name}-nic"
  resource_group_name = azurerm_resource_group.vm.name
  location = azurerm_resource_group.vm.location
  ip_configuration {
    name = "external"
    subnet_id = var.vms_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm.id
  }
}

resource "azurerm_network_security_group" "vm" {
  name = "$(azurerm_network_interface.vm.name)-nsg"
  resource_group_name = azurerm_resource_group.vm.name
  location = azurerm_resource_group.vm.location
  security_rule { 
    name = "allow_ssh_from_my_ip"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    destination_port_range = "22"
    source_address_prefix = var.public_ip #"10.0.2.0/24"
    destination_adress_prefix = "*" 
    source_port_range = "*"
  }

  security_rule {
    name = "allow_http_from_my_ip"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    destination_port_range = "80"
    source_address_prefix =var.public_ip # "10.0.2.0/24"
    destination_adress_prefix = "*"
    source_port_range = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nsg_to_vm_nic" {
  network_interface_id = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

#
################## VM ####################
#


resource "azurerm_linux_virtual_machine" "web_srv" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.vm.id]
  disable_password_authentication = false
  admin_password = var.password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
