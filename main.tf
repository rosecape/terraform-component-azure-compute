locals {
  node_pools = {
    "main" = {
      name                = "main"
      vm_size             = "Standard_D4s_v3"
      min_count           = 0
      max_count           = 5
      enable_auto_scaling = true
      vnet_subnet_id      = var.vnet_subnet_id
      node_taints         = ["dedicated=generalGroup:NoSchedule"]
      node_labels = {
        "dedicated" = "generalGroup"
      }
    },
    "compute" = {
      name                = "memory"
      vm_size             = "Standard_B8ms"
      min_count           = 0
      max_count           = 5
      enable_auto_scaling = true
      vnet_subnet_id      = var.vnet_subnet_id
      node_taints         = ["dedicated=memoryGroup:NoSchedule"]
      node_labels = {
        "dedicated" = "memoryGroup"
      }
    }
  }
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "8.0.0"

  prefix                            = var.name
  resource_group_name               = var.resource_group_name
  os_disk_size_gb                   = var.os_disk_size_gb
  sku_tier                          = var.sku_tier
  rbac_aad                          = var.rbac_aad
  agents_min_count                  = var.agents_min_count
  agents_max_count                  = var.agents_max_count
  enable_auto_scaling               = var.enable_auto_scaling
  temporary_name_for_rotation       = var.temporary_name_for_rotation
  role_based_access_control_enabled = var.role_based_access_control_enabled
  vnet_subnet_id                    = var.vnet_subnet_id
  agents_size                       = "Standard_B2s"
  node_pools                        = local.node_pools
  only_critical_addons_enabled      = true
}

resource "azurerm_storage_account" "airflow" {
  name                     = "productionairflowsa"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "airflow_logs" {
  name                  = "airflow-logs"
  storage_account_name  = azurerm_storage_account.airflow.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "prune_logs" {
  storage_account_id = azurerm_storage_account.airflow.id

  rule {
    name    = "prune-logs"
    enabled = true
    filters {
      prefix_match = ["airflow-logs"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }
}
