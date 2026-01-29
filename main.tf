locals {
  # Define the environment prefix
  kube_resource_group_name = "${var.env_prefix}-${var.kube_resource_group_name}"
  cluster_name             = "${var.env_prefix}-${var.cluster_name}"
  kube_vnet_name           = "${var.env_prefix}-${var.kube_vnet_name}"
}

resource "azurerm_resource_group" "kube" {
  name     = local.kube_resource_group_name # Use the local value
  location = var.location
  tags = {
    environment = "Demo"
  }
}

module "kube_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  vnet_name           = local.kube_vnet_name # Use the local value
  address_space       = var.address_space
  subnets             = var.subnets
}

module "vm" {
  source = "./modules/vm"

  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  env_prefix          = var.env_prefix

  vnet_id    = module.kube_network.vnet_id
  subnet_ids = module.kube_network.subnet_ids

  vms       = var.vms
  nsg_rules = var.vm_nsg_rules

  tags = {
    Project    = "GitOps-AKS"
    CostCenter = "Infrastructure"
  }

  depends_on = [module.kube_network]
}

locals {
  vm_role_groups_base = module.vm.vm_role_groups

  vm_role_groups_merged = var.merge_vmselect_vminsert_when_sparse ? merge(
    local.vm_role_groups_base,
    {
      vmselect = distinct(concat(
        lookup(local.vm_role_groups_base, "vmselect", []),
        lookup(local.vm_role_groups_base, "vminsert", [])
      ))
      vminsert = distinct(concat(
        lookup(local.vm_role_groups_base, "vmselect", []),
        lookup(local.vm_role_groups_base, "vminsert", [])
      ))
    }
  ) : local.vm_role_groups_base

  inventory_groups_pre_children = [
    for group in distinct(concat(var.inventory_groups_order, sort(keys(local.vm_role_groups_merged)))) : group
    if length(lookup(local.vm_role_groups_merged, group, [])) > 0 && !contains(var.inventory_groups_post_children, group)
  ]

  inventory_groups_post_children_explicit = [
    for group in var.inventory_groups_post_children : group
    if length(lookup(local.vm_role_groups_merged, group, [])) > 0
  ]

  inventory_groups_remaining = [
    for group in sort(keys(local.vm_role_groups_merged)) : group
    if length(lookup(local.vm_role_groups_merged, group, [])) > 0 &&
    !contains(local.inventory_groups_pre_children, group) &&
    !contains(local.inventory_groups_post_children_explicit, group)
  ]

  inventory_groups_post_children = concat(
    local.inventory_groups_post_children_explicit,
    local.inventory_groups_remaining
  )

  inventory_cluster_children_filtered = [
    for child in var.inventory_cluster_children : child
    if length(lookup(local.vm_role_groups_merged, child, [])) > 0
  ]
}

resource "local_file" "cluster_inventory" {
  content = templatefile("${path.module}/templates/cluster_inventory.tpl", {
    groups               = local.vm_role_groups_merged
    groups_pre_children  = local.inventory_groups_pre_children
    groups_post_children = local.inventory_groups_post_children
    cluster_children     = local.inventory_cluster_children_filtered
  })

  filename = "${path.module}/${var.inventory_output_path}"
}