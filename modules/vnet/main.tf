resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation == "Microsoft.ContainerService/managedClusters" ? [1] : []
    content {
      name = "aks_delegation"
      service_delegation {
        name = "Microsoft.ContainerService/managedClusters"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        ]
      }
    }
  }
  dynamic "delegation" {
    for_each = each.value.delegation == "Microsoft.ServiceNetworking/trafficControllers" ? [1] : []
    content {
      name = "ingress_delegation"
      service_delegation {
        name = "Microsoft.ServiceNetworking/trafficControllers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        ]
      }
    }
  }
  dynamic "delegation" {
    for_each = each.value.delegation == "Microsoft.DBforMySQL/flexibleServers" ? [1] : []
    content {
      name = "mysql_flexible_servers"
      service_delegation {
        name = "Microsoft.DBforMySQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        ]
      }
    }
  }
}