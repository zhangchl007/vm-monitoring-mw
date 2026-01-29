locals {
  global_tags = merge(
    {
      Environment = var.env_prefix
      ManagedBy   = "Terraform"
      Component   = "vm"
    },
    var.tags
  )
  role_tags = {
    for name, cfg in var.vms :
    name => (length(lookup(cfg, "roles", [])) > 0 ? { Roles = join(",", lookup(cfg, "roles", [])) } : {})
  }
  shared_nsg_name = "${var.env_prefix}-vm-nsg"
}

# Public IPs for VMs (optional)
resource "azurerm_public_ip" "vm" {
  for_each = {
    for name, config in var.vms : name => config
    if config.enable_public_ip
  }

  name                = "${var.env_prefix}-${each.value.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(
    local.global_tags,
    local.role_tags[each.key],
    each.value.tags
  )
}

# Network Security Group (shared)
resource "azurerm_network_security_group" "vm" {
  name                = local.shared_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Network Interfaces
resource "azurerm_network_interface" "vm" {
  for_each = var.vms

  name                = "${var.env_prefix}-${each.value.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = merge(
    local.global_tags,
    local.role_tags[each.key],
    each.value.tags
  )

  ip_configuration {
    name                          = "${each.value.vm_name}-ip-config"
    subnet_id                     = var.subnet_ids[each.value.subnet_name]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.enable_public_ip ? azurerm_public_ip.vm[each.key].id : null
  }
}

# Associate NSGs with NICs
resource "azurerm_network_interface_security_group_association" "vm" {
  for_each = var.vms

  network_interface_id      = azurerm_network_interface.vm[each.key].id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = {
    for name, config in var.vms : name => config
    if lower(config.os_type) == "linux"
  }

  name                = "${var.env_prefix}-${each.value.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.vm_size

  admin_username = each.value.admin_username

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file(each.value.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  network_interface_ids = [
    azurerm_network_interface.vm[each.key].id,
  ]

  tags = merge(
    local.global_tags,
    local.role_tags[each.key],
    each.value.tags
  )

  depends_on = [azurerm_network_interface_security_group_association.vm]
}

# Windows Virtual Machines
resource "azurerm_windows_virtual_machine" "vm" {
  for_each = {
    for name, config in var.vms : name => config
    if lower(config.os_type) == "windows"
  }

  name                = "${var.env_prefix}-${each.value.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.vm_size

  admin_username = each.value.admin_username
  admin_password = random_password.vm_password[each.key].result

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  network_interface_ids = [
    azurerm_network_interface.vm[each.key].id,
  ]

  tags = merge(
    local.global_tags,
    local.role_tags[each.key],
    each.value.tags
  )

  depends_on = [azurerm_network_interface_security_group_association.vm]
}

# Generate random passwords for Windows VMs
resource "random_password" "vm_password" {
  for_each = {
    for name, config in var.vms : name => config
    if lower(config.os_type) == "windows"
  }

  length  = 16
  special = true
}

# Custom Script Extension for Linux VMs
resource "azurerm_virtual_machine_extension" "linux_custom_script" {
  for_each = {
    for name, config in var.vms : name => config
    if lower(config.os_type) == "linux" && config.custom_script != ""
  }

  name                 = "${each.value.vm_name}-custom-script"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = jsonencode({
    commandToExecute = each.value.custom_script
  })

  depends_on = [azurerm_linux_virtual_machine.vm]
}
