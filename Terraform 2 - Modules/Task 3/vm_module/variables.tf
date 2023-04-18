variable "base_name" {
type = string
description = "Base name"
}

variable "location" {
type = string
description = "Resources are stored in this location"
}

variable "vms_subnet_id" {
type = string
description = "subnet"
#default = azurerm_subnet.general_network_vms.id
}

variable "public_ip" {
type = string
description = "public ip address"
}

variable "password" {
type = string
description = "secret password"
}