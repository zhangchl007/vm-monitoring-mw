locals {
  all_virtual_machines = merge(
    azurerm_linux_virtual_machine.vm,
    azurerm_windows_virtual_machine.vm,
  )

  vm_details = {
    for name, vm in local.all_virtual_machines : name => {
      vm_id                 = vm.id
      vm_name               = vm.name
      computer_name         = vm.computer_name
      admin_username        = vm.admin_username
      private_ip_address    = vm.private_ip_address
      public_ip_address     = vm.public_ip_address
      network_interface_ids = vm.network_interface_ids
      tags                  = vm.tags
      zone                  = try(vm.zone, null)
      roles                 = lookup(var.vms[name], "roles", [])
    }
  }

  vm_role_groups = {
    for role in distinct(flatten([
      for cfg in var.vms : lookup(cfg, "roles", [])
      ])) : role => [
      for name, details in local.vm_details : details.vm_name
      if contains(details.roles, role)
    ]
  }
}

output "vm_details" {
  description = "Per-VM facts (ids, names, IPs, NICs, tags, zone)"
  value       = local.vm_details
}

output "vm_ids" {
  description = "Map of VM IDs"
  value = {
    for name, details in local.vm_details : name => details.vm_id
  }
}

output "vm_ip_addresses" {
  description = "Private and public IPs per VM"
  value = {
    for name, details in local.vm_details : name => {
      private = details.private_ip_address
      public  = details.public_ip_address
    }
  }
}

output "vm_network_interface_ids" {
  description = "NIC ids attached to each VM"
  value = {
    for name, details in local.vm_details : name => details.network_interface_ids
  }
}

output "vm_network_security_group" {
  description = "Shared NSG applied to all VM NICs"
  value = {
    id                  = azurerm_network_security_group.vm.id
    name                = azurerm_network_security_group.vm.name
    location            = azurerm_network_security_group.vm.location
    resource_group_name = azurerm_network_security_group.vm.resource_group_name
  }
}

output "vm_role_groups" {
  description = "Map of role name to VM hostnames"
  value       = local.vm_role_groups
}
