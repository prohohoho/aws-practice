# Locals block for hardcoded names
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.test.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.test.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.test.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.test.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.test.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.test.name}-rqrt"
  #app_gateway_subnet_name        = "appgwsubnet"
  app_gateway_subnet_name        = "${var.CLUSTER_NAME}-${var.ENV_NAME}-appgwsubnet"
}

## Create a resource group to place resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.CLUSTER_NAME}-${var.ENV_NAME}-rg"
  location = "${var.CLUSTER_RG_LOCATION}"
}


# User Assigned Identities 
resource "azurerm_user_assigned_identity" "testIdentity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name =  "${var.CLUSTER_NAME}-${var.ENV_NAME}-identity"
  tags = var.tags
}



resource "azurerm_virtual_network" "test" {
  name                = "${var.CLUSTER_NAME}-${var.ENV_NAME}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.virtual_network_address_prefix,var.virtual_network_address_prefix2]

  subnet {
    name           = "${var.CLUSTER_NAME}-${var.ENV_NAME}-subnet"
    address_prefix = var.aks_subnet_address_prefix
  }

  subnet {
    name           = local.app_gateway_subnet_name 
    address_prefix = var.app_gateway_subnet_address_prefix
  }

  tags = var.tags
}

data "azurerm_subnet" "kubesubnet" {
  name                 = "${var.CLUSTER_NAME}-${var.ENV_NAME}-subnet"
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_virtual_network.test]
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = local.app_gateway_subnet_name
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_virtual_network.test]
}

# Public Ip 
resource "azurerm_public_ip" "test" {
  name                = "${var.CLUSTER_NAME}-${var.ENV_NAME}-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}





 #resource "azurerm_role_assignment" "ra1" {
 #  scope                = data.azurerm_subnet.kubesubnet.id
 #  role_definition_name = "Network Contributor"
 #  principal_id         = var.AKS_SP_OBID
 #  depends_on = [azurerm_virtual_network.test]
 #}
 #resource "azurerm_role_assignment" "ra2" {
 #  scope                = azurerm_user_assigned_identity.testIdentity.id
 #  role_definition_name = "Managed Identity Operator"
 #  principal_id         = var.AKS_SP_OBID
 #  depends_on           = [azurerm_user_assigned_identity.testIdentity]
 #}
 #resource "azurerm_role_assignment" "ra3" {
 #  scope                = azurerm_application_gateway.network.id
 #  role_definition_name = "Contributor"
 #  principal_id         = azurerm_user_assigned_identity.testIdentity.principal_id
 #  depends_on           = [azurerm_user_assigned_identity.testIdentity, azurerm_application_gateway.network]
 #}
 #resource "azurerm_role_assignment" "ra4" {
 #  scope                = azurerm_resource_group.rg.id
 #  role_definition_name = "Reader"
 #  principal_id         = azurerm_user_assigned_identity.testIdentity.principal_id
 #  depends_on           = [azurerm_user_assigned_identity.testIdentity, azurerm_application_gateway.network]
 #}


#--------------create cluster--------

#create Log analytics insigts
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${var.CLUSTER_NAME}-${var.ENV_NAME}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
}


resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.CLUSTER_NAME}-${var.ENV_NAME}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.CLUSTER_NAME}-${var.ENV_NAME}"

  default_node_pool {
    name       = "agentpool"    
    vm_size    = "${var.aks_agent_vm_size}"
    type       = "VirtualMachineScaleSets"
    node_count      = var.aks_agent_count    
    #os_disk_size_gb = var.aks_agent_os_disk_size   
    vnet_subnet_id  = data.azurerm_subnet.kubesubnet.id
    enable_auto_scaling  = true
    max_count            = 6
    min_count            = 2
    availability_zones   =[1]
  }

 

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
    }

   

  }

  #identity {
  #  type = "SystemAssigned"
  #}

  tags = {
    environment = "prod"
    cluster_name = "${var.CLUSTER_NAME}"
  }

  service_principal {
    client_id     = var.SP_CLIENT_ID
    client_secret = var.SP_CLIENT_SECRET
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {  
    load_balancer_sku  = "Standard"    
    network_plugin     = "azure"    
  }


  depends_on = [azurerm_log_analytics_workspace.insights,azurerm_virtual_network.test ]
}
