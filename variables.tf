variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "subnet_prefix" {
  description = "The address prefix for the subnet"
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group"
  type        = string
}

variable "subnets" {
  description = "Map of subnet names to configuration"
  type = map(object({
    name           = string
    address_prefix = string
    nsg_id         = optional(string)
  }))
  default = {}
}

// Add docker_bridge_cidr variable since it's used but not defined
variable "docker_bridge_cidr" {
  description = "The Docker bridge CIDR for the AKS cluster"
  type        = string
  default     = "172.17.0.1/16"
  validation {
    condition     = can(cidrhost(var.docker_bridge_cidr, 0))
    error_message = "docker_bridge_cidr must be a valid CIDR block"
  }
}

# AKS Cluster Variables
variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "example-aks"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}$", var.aks_cluster_name))
    error_message = "AKS cluster name must be 1-63 characters of alphanumeric characters and hyphens"
  }
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy"
  type        = string
  default     = "1.26.3"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "Kubernetes version must be in the format X.Y.Z"
  }
}

variable "network_plugin" {
  description = "Network plugin for AKS. Values: azure or kubenet"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy for AKS. Values: azure or calico"
  type        = string
  default     = "azure"
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery"
  type        = string
  default     = "10.0.0.10"
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.dns_service_ip))
    error_message = "dns_service_ip must be a valid IP address"
  }
}

variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "service_cidr must be a valid CIDR block"
  }
}

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone for private cluster"
  type        = string
  default     = null
}

variable "admin_group_object_ids" {
  description = "AD Group Object IDs that will have admin access to the cluster"
  type        = list(string)
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster"
  type        = string
  default     = "Standard"
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for the AKS cluster"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["none", "patch", "stable", "rapid", "node-image"], var.automatic_channel_upgrade)
    error_message = "automatic_channel_upgrade must be one of: none, patch, stable, rapid, node-image"
  }
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = list(object({
      end   = string
      start = string
    }))
  })
  default = null
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for Containers"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable workload identity"
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer"
  type        = bool
  default     = true
}

variable "enable_managed_prometheus" {
  description = "Enable Azure Managed Prometheus"
  type        = bool
  default     = true
}

# Node Pool Variables
variable "system_node_pool_name" {
  description = "The name of the system node pool"
  type        = string
  default     = "systempool"
}

variable "system_node_pool_vm_size" {
  description = "The size of the system node pool VMs"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "system_node_pool_node_count" {
  description = "The initial number of nodes in system node pool"
  type        = number
  default     = 1
}

variable "system_node_pool_enable_auto_scaling" {
  description = "Enable auto scaling for system node pool"
  type        = bool
  default     = true
}

variable "system_node_pool_min_count" {
  description = "Minimum number of nodes for system node pool auto scaling"
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "Maximum number of nodes for system node pool auto scaling"
  type        = number
  default     = 3
}

variable "system_node_pool_os_disk_size_gb" {
  description = "OS Disk size for system node pool VMs"
  type        = number
  default     = 30
}

variable "system_node_pool_type" {
  description = "The type of system node pool"
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "system_node_pool_zones" {
  description = "List of availability zones for system node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# User Node Pool Variables
variable "work_node_pool_name" {
  description = "The name of the user node pool"
  type        = string
  default     = "workpool"
}

variable "work_node_pool_vm_size" {
  description = "The size of the user node pool VMs"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "work_node_pool_enable_auto_scaling" {
  description = "Enable auto scaling for user node pool"
  type        = bool
  default     = true
}

variable "work_node_pool_min_count" {
  description = "Minimum number of nodes for user node pool auto scaling"
  type        = number
  default     = 1
}

variable "work_node_pool_max_count" {
  description = "Maximum number of nodes for user node pool auto scaling"
  type        = number
  default     = 5
}

variable "work_node_pool_os_disk_size_gb" {
  description = "OS Disk size for user node pool VMs"
  type        = number
  default     = 50
}

variable "work_node_pool_zones" {
  description = "List of availability zones for user node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "identity_type" {
  description = "The type of identity used for the cluster"
  type        = string
  default     = "SystemAssigned"
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy Add-on"
  type        = bool
  default     = true
}

variable "oms_agent_enabled" {
  description = "Enable OMS agent for monitoring"
  type        = bool
  default     = true
}

// Remove the log_analytics_workspace_id variable since it's created by the module

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace"
  default     = "aks-monitoring-workspace"
}

variable "log_analytics_workspace_sku" {
  type        = string
  description = "SKU of the Log Analytics workspace"
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Data retention in days for Log Analytics"
  default     = 30
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

variable "environment" {
  description = "Environment name for the resources"
  type        = string
  default     = "prod"
}

variable "keyvault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "keyvault_sku" {
  description = "SKU name of the Key Vault"
  type        = string
  default     = "standard"
}

variable "keyvault_network_acls" {
  description = "Network ACLs for the Key Vault"
  type = object({
    bypass                     = string
    default_action            = string
    ip_rules                  = list(string)
    virtual_network_subnet_ids = list(string)
  })
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters long and can only contain lowercase letters and numbers"
  }
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "documents"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.container_name))
    error_message = "Container name must be between 3 and 63 characters, start with letter or number, and can only contain lowercase letters, numbers, and hyphens"
  }
}

variable "grafana_name" {
  description = "Name of the Azure Managed Grafana instance"
  type        = string
  default     = "aks-grafana"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}$", var.grafana_name))
    error_message = "Grafana name must be 1-63 characters of alphanumeric characters and hyphens"
  }
}

variable "bastion_host_name" {
  description = "Name of the Azure Bastion Host"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,80}$", var.bastion_host_name))
    error_message = "Bastion host name must be between 1 and 80 characters, containing alphanumeric characters and hyphens"
  }
}

variable "enable_versioning" {
  description = "Enable blob versioning for the storage account"
  type        = bool
  default     = true
}

variable "container_soft_delete_retention" {
  description = "Number of days to retain deleted container"
  type        = number
  default     = 7
}

variable "blob_soft_delete_retention" {
  description = "Number of days to retain deleted blobs"
  type        = number
  default     = 7
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 characters long and can only contain alphanumeric characters"
  }
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, or Premium"
  }
}

variable "acr_public_access_enabled" {
  description = "Whether to enable public access for the Azure Container Registry"
  type        = bool
  default     = false
}

// MySQL Flexible Server Variables
variable "mysql_server_name" {
  description = "Name of the MySQL Flexible Server"
  type        = string
}

variable "mysql_admin_username" {
  description = "Administrator username for MySQL server"
  type        = string
}

variable "mysql_admin_password" {
  description = "Administrator password for MySQL server"
  type        = string
  sensitive   = true
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0.21"
}

variable "mysql_sku_name" {
  description = "SKU name for MySQL Flexible Server"
  type        = string
  default     = "GP_Standard_D2ds_v4"
}

variable "mysql_storage_iops" {
  description = "Storage IOPS for MySQL server"
  type        = number
  default     = 396
}

variable "mysql_storage_size_gb" {
  description = "Storage size in GB for MySQL server"
  type        = number
  default     = 32
}

variable "mysql_backup_retention_days" {
  description = "Backup retention days for MySQL server"
  type        = number
  default     = 7
}

variable "mysql_zone" {
  description = "Availability zone for MySQL server"
  type        = string
  default     = "1"
}

variable "mysql_standby_zone" {
  description = "Availability zone for MySQL standby server"
  type        = string
  default     = "2"
}

variable "mysql_high_availability_mode" {
  description = "High availability mode for MySQL server"
  type        = string
  default     = "ZoneRedundant"
}

variable "mysql_maintenance_window" {
  description = "Maintenance window for MySQL server"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
}

# Linux VM Variables
variable "linux_vm_name" {
  description = "Name of the Linux VM"
  type        = string
}

variable "linux_vm_size" {
  description = "Size of the Linux VM"
  type        = string
}

variable "linux_admin_username" {
  description = "Admin username for the Linux VM"
  type        = string
}

variable "linux_os_disk_type" {
  description = "OS disk type for Linux VM"
  type        = string
}

variable "linux_os_disk_size_gb" {
  description = "OS disk size in GB for Linux VM"
  type        = number
}

variable "linux_admin_password" {
  description = "The password for the Linux VM admin user. Must be between 6-72 characters long and must satisfy at least 3 password complexity requirements"
  type        = string
  sensitive   = true
}