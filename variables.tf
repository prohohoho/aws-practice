#------------VNET------------------

variable "virtual_network_address_prefix" {
    description = "VNET address prefix"
    default     = "172.23.0.0/16"
}

variable "virtual_network_address_prefix2" {
    description = "VNET address prefix"
    default     = "172.24.0.0/16"
}


variable "aks_subnet_address_prefix" {
    description = "Subnet address prefix."
    default     = "172.23.0.0/24"
}

variable "app_gateway_subnet_address_prefix" {
    description = "Subnet server IP address."
    default     = "172.24.0.0/16"
}



variable "app_gateway_sku" {
    description = "Name of the Application Gateway SKU"
    default = "Standard_v2"
}

variable "app_gateway_tier" {
    description = "Tier of the Application Gateway tier"
    default = "Standard_v2"
}




#----------AKS Basic config---------------
variable "CLUSTER_RG_LOCATION" {
description = "contains the location Resource Group of cluster"
#default = "australiaeast"
type = string

}



variable "SP_CLIENT_ID" {
  description = "Object ID of the service principal."
}


variable "SP_CLIENT_SECRET" {
  description = "Object ID of the service principal."
}


variable "AKS_SP_OBID" {
  description = "Object ID of the service principal."
}

variable "ENV_NAME" {
  description = "The environment for the AKS cluster"  
  type = string
}



variable "CLUSTER_NAME" {
    description = "AKS cluster name"    
    type = string
}


variable "aks_agent_os_disk_size" {
    description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
    default     = 0
    type = string
}

variable "aks_agent_count" {
    description = "The number of agent nodes for the cluster."
    default     = 4
    type = string
}

variable "aks_agent_vm_size" {
    description = "VM size"
    default     = "Standard_D4s_v3"
    type = string
}

variable "kubernetes_version" {
    description = "Kubernetes version"
    default     = "1.23.5"
    type = string
}

variable "aks_service_cidr" {
    description = "CIDR notation IP range from which to assign service cluster IPs"
    default     = "10.0.0.0/16"
    type = string
}

variable "aks_dns_service_ip" {
    description = "DNS server IP address"
    default     = "10.0.0.10"
    type = string
}

variable "aks_docker_bridge_cidr" {
    description = "CIDR notation IP for Docker bridge."
    default     = "172.17.0.1/16" 
    type = string
}

variable "aks_enable_rbac" {
    description = "Enable RBAC on the AKS cluster. Defaults to false."
    default     = "false"    
    type = string
}


variable "tags" {
    type = map(string)

    default = {
    source = "terraform"
    }
}

