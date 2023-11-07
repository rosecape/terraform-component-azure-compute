locals {
  node_pools = {
    "main" = {
      name                = substr("worker${i}${random_id.prefix.hex}", 0, 8)
      vm_size             = "Standard_D2s_v3"
      min_count           = 0
      max_count           = 2
      enable_auto_scaling = true
      vnet_subnet_id      = var.vnet_subnet_id
    }
  }
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "7.4.0"

  prefix                      = var.name
  resource_group_name         = var.resource_group_name
  os_disk_size_gb             = var.os_disk_size_gb
  sku_tier                    = var.sku_tier
  rbac_aad                    = var.rbac_aad
  agents_min_count            = var.agents_min_count
  agents_max_count            = var.agents_max_count
  enable_auto_scaling         = var.enable_auto_scaling
  temporary_name_for_rotation = var.temporary_name_for_rotation
  # network_plugin                    = var.network_plugin
  # network_policy                    = var.network_policy
  role_based_access_control_enabled = var.role_based_access_control_enabled
  vnet_subnet_id                    = var.vnet_subnet_id

  #   agents_size                   = "Standard_B2s"
}
