variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix for naming"
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs map from vnet module"
  type        = map(string)
}

variable "vms" {
  description = "Map of VMs to create with custom configuration"
  type = map(object({
    vm_name             = string
    vm_size             = string
    subnet_name         = string
    admin_username      = string
    ssh_public_key_path = string
    os_type             = optional(string, "linux")
    image_publisher     = optional(string, "Canonical")
    image_offer         = optional(string, "0001-com-ubuntu-server-focal")
    image_sku           = optional(string, "20_04-lts-gen2")
    image_version       = optional(string, "latest")
    enable_public_ip    = optional(bool, true)
    custom_script       = optional(string, "")
    roles               = optional(list(string), [])
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "nsg_rules" {
  description = "Shared NSG rules for all VMs"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to VM resources"
  type        = map(string)
  default     = {}
}