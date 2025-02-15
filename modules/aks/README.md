# Azure Kubernetes Service (AKS) Module

A comprehensive Terraform module for deploying production-ready Azure Kubernetes Service clusters with best practices.

## Prerequisites and Setup

### 1. Required Azure CLI Extensions
```bash
# Install/update AKS preview extension
az extension add --name aks-preview
az extension update --name aks-preview

# Install Azure AD extension
az extension add --name azure-cli-ml
```

### 2. Required Role Assignments
Ensure you have the following roles:
- "Azure Kubernetes Service Cluster Admin Role"
- "Network Contributor" (for VNet integration)
- "User Access Administrator" (for assigning roles)

### 3. Gathering Required Credentials

#### Azure AD Group Setup for AKS Admin Access
```bash
# Create an Azure AD Admin Group if not exists
az ad group create --display-name "AKS-Cluster-Admins" --mail-nickname "aks-cluster-admins"

# Add users to the admin group
az ad group member add --group "AKS-Cluster-Admins" --member-id "user-object-id"

# Get admin_group_object_ids (required for terraform.tfvars)
az ad group show --group "AKS-Cluster-Admins" --query id -o tsv
```

#### User-Assigned Managed Identity (Optional)
```bash
# Create User-Assigned Managed Identity
az identity create --name "aks-identity" --resource-group "your-rg-name" --location "your-location"

# Get the identity ID and client ID
az identity show --name "aks-identity" --resource-group "your-rg-name"
```

#### Workload Identity Setup
```bash
# Enable OIDC issuer feature
az feature register --namespace "Microsoft.ContainerService" --name "AKS-AADWorkloadIdentity"

# Check registration status
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AADWorkloadIdentity')].{Name:name,State:properties.state}"

# When ready, refresh the registration
az provider register --namespace Microsoft.ContainerService
```

## Features

- Private cluster deployment with Azure CNI networking
- Multi-availability zone system and user node pools
- Autoscaling configuration with optimization profiles
- Azure AD RBAC integration
- Microsoft Defender for Containers integration
- Azure Monitor integration with Log Analytics
- Workload Identity and OIDC support
- Maintenance window configuration
- Azure Linux (CBL-Mariner) node OS

## Usage

```hcl
module "aks" {
  source = "./modules/aks"

  # Core Configuration
  cluster_name         = "prod-aks-cluster"
  location            = "eastus"
  resource_group_name = module.resource_group.name
  kubernetes_version  = "1.26"

  # Node Pool Configuration
  system_node_pool = {
    name         = "system"
    vm_size      = "Standard_D4s_v3"
    min_count    = 1
    max_count    = 3
    zones        = [1, 2, 3]
    node_labels  = { "role" = "system" }
    node_taints  = ["CriticalAddonsOnly=true:NoSchedule"]
  }

  user_node_pool = {
    name         = "user"
    vm_size      = "Standard_D4s_v3"
    min_count    = 1
    max_count    = 5
    zones        = [1, 2, 3]
    node_labels  = { "role" = "user" }
  }

  # Networking
  vnet_subnet_id = module.subnet.id
  network_plugin = "azure"
  network_policy = "azure"
  
  # Identity and Security
  admin_group_object_ids = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
  
  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| cluster_name | The name of the AKS cluster | string | yes | - |
| location | Azure region for the cluster | string | yes | - |
| resource_group_name | Name of the resource group | string | yes | - |
| kubernetes_version | Kubernetes version | string | yes | - |
| vnet_subnet_id | Subnet ID for CNI networking | string | yes | - |
| admin_group_object_ids | AAD group IDs for admin access | list(string) | yes | - |
| system_node_pool | System node pool configuration | map(any) | yes | {} |
| user_node_pool | User node pool configuration | map(any) | yes | {} |
| log_analytics_workspace_id | Log Analytics Workspace ID | string | yes | - |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The AKS cluster ID |
| cluster_fqdn | The FQDN of the AKS cluster |
| kube_config | Kubeconfig credentials |
| cluster_identity | The system-assigned identity |
| kubelet_identity | The kubelet identity |

## Advanced Features

### Node Pool Autoscaling
The module configures optimized autoscaling profiles:
- Balanced node distribution
- Fast scale-down for cost optimization
- System pod protection
- Local storage handling

### Security Features
- Private cluster endpoints
- Azure AD RBAC integration
- Network policies
- Microsoft Defender integration
- Workload Identity

### Monitoring and Diagnostics
- Azure Monitor integration
- Log Analytics integration
- Custom diagnostic settings
- Metric collection

## Notes

- The cluster uses Azure CNI networking for advanced networking features
- System node pool is tainted for system workloads only
- Multi-zone deployment ensures high availability
- Workload Identity requires Azure AD integration