output "object_id" {
  value = data.azurerm_client_config.current.object_id
}

output "vm_role_groups" {
  description = "Role-to-hostname mapping derived from the VM module"
  value       = module.vm.vm_role_groups
}

output "cluster_inventory_file" {
  description = "Absolute path to the rendered cluster inventory"
  value       = local_file.cluster_inventory.filename
}