locals {

  node_pools = length(var.node_pools) > 0 ? var.node_pools : tomap(
    {
      "core" = {
        name                = "core"
        vm_size             = "Standard_B4ms"
        min_count           = 0
        max_count           = 1
        enable_auto_scaling = true
        vnet_subnet_id      = var.vnet_subnet_id
        node_taints         = ["dedicated=coreGroup:NoSchedule"]
        node_labels = {
          "dedicated" = "coreGroup"
        }
      },
      "main" = {
        name                = "main"
        vm_size             = "Standard_D4s_v3"
        min_count           = 0
        max_count           = 5
        enable_auto_scaling = true
        vnet_subnet_id      = var.vnet_subnet_id
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
      },
      "workers" = {
        priority            = "Spot"
        eviction_policy     = "Delete"
        spot_max_price      = -1
        name                = "workers"
        vm_size             = "Standard_B2s_v2"
        min_count           = 0
        max_count           = 5
        enable_auto_scaling = true
        vnet_subnet_id      = var.vnet_subnet_id
        node_taints = [
          "dedicated=workerGroup:NoSchedule",
          "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
        ]
        node_labels = {
          "dedicated"                             = "workerGroup"
          "kubernetes.azure.com/scalesetpriority" = "spot"
        }
      }
    },
  )
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "9.1.0"

  prefix                              = var.name
  resource_group_name                 = var.resource_group_name
  node_resource_group                 = try(var.node_resource_group_name, var.resource_group_name)
  os_disk_size_gb                     = var.os_disk_size_gb
  sku_tier                            = var.sku_tier
  rbac_aad                            = var.rbac_aad
  agents_size                         = "Standard_B2s_v2"
  agents_min_count                    = var.agents_min_count
  agents_max_count                    = var.agents_max_count
  enable_auto_scaling                 = var.enable_auto_scaling
  temporary_name_for_rotation         = var.temporary_name_for_rotation
  net_profile_dns_service_ip          = var.net_profile_dns_service_ip
  net_profile_service_cidr            = var.net_profile_service_cidr
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  vnet_subnet_id                      = var.vnet_subnet_id
  node_pools                          = local.node_pools
  key_vault_secrets_provider_enabled  = true
  workload_identity_enabled           = true
  oidc_issuer_enabled                 = true
  storage_profile_blob_driver_enabled = true
  only_critical_addons_enabled        = true
  log_analytics_workspace_enabled     = false
}

resource "azurerm_storage_account" "airflow" {
  name                     = var.airflow_storage_account_name
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

resource "azurerm_container_registry" "acr" {
  count               = var.create_acr_registry ? 1 : 0
  name                = "rosecapev2"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  admin_enabled       = true
}

# Azure Container Registry - Git Actions
data "azuread_service_principal" "git_actions_acr_push" {
  count = var.create_acr_registry ? 1 : 0

  display_name = "git-actions-acr-push"
}

resource "azurerm_role_assignment" "acr" {
  count = var.create_acr_registry ? 1 : 0

  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPush"
  principal_id         = data.azuread_service_principal.git_actions_acr_push.object_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  count = var.create_acr_registry ? 1 : 0

  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = one(module.aks.kubelet_identity).object_id
}
