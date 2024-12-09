variable "agents_max_count" {
  description = "Maximum number of agents in the agent pool."
  type        = number
  default     = 2
}

variable "agents_min_count" {
  description = "Minimum number of agents in the agent pool."
  type        = number
  default     = 1
}

variable "airflow_storage_account_name" {
  description = "Name of the storage account for Airflow logs."
  type        = string
  default     = null
}

variable "create_acr_registry" {
  description = "Create an Azure Container Registry."
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling of the agent pool."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the deployment"
  type        = string
}

variable "net_profile_dns_service_ip" {
  description = "The IP address of the DNS server used by the Kubernetes service."
  type        = string
  default     = null
}

variable "net_profile_service_cidr" {
  description = "The Network Range used by the Kubernetes service."
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "Network plugin to use for networking. Defaults to azure for basic networking or kubenet for advanced networking."
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy to use for Kubernetes. Defaults to calico."
  type        = string
  default     = "calico"
}

variable "node_pools" {
  description = "List of maps containing the properties of the node pools."
  type        = any
  default     = []
}

variable "node_resource_group_name" {
  description = "Name of the resource group in which to create the AKS node pool."
  type        = string
}

variable "os_disk_size_gb" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023."
  type        = number
  default     = 60
}

variable "rbac_aad" {
  description = "Enable Azure Active Directory RBAC integration for cluster."
  type        = bool
  default     = false
}

variable "resource_group_location" {
  description = "Location of the resource group in which to create the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "role_based_access_control_enabled" {
  description = "Enable Kubernetes Role-Based Access Control"
  type        = bool
  default     = true
}

variable "sku_tier" {
  description = "The SKU Tier of the Managed Kubernetes Cluster. Possible values are Free and Paid."
  type        = string
  default     = "Free"
}

variable "temporary_name_for_rotation" {
  description = "Temporary name for rotation"
  type        = string
  default     = "aksrotation"
}

variable "vnet_subnet_id" {
  description = "The ID of a Subnet where the Kubernetes Node Pool should exist."
  type        = string
}
