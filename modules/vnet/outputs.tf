output "vnet_id" {
  description = "Generated VNET ID"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Generated subnet IDs map"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}

output "subnet_names" {
  description = "Map of subnet names"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.name }
}

