terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = var.resource_group_name
  location            = var.location
}

data "azurerm_virtual_desktop_host_pool" "this" {
  name                = var.host_pool
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_desktop_application_group" "this" {
  name                = var.appgroupname
  resource_group_name = var.resource_group_name
  location            = var.location
  host_pool_id        = data.azurerm_virtual_desktop_host_pool.this.id
  type                = "Desktop"
}

# A vnet is required for the private endpoint.
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "this" {
  name                 = module.naming.subnet.name_unique
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.wvd.microsoft.com"
  resource_group_name = var.resource_group_name
}

# This is the module call
module "workspace" {
  source              = "../../"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace           = var.workspace
  subresource_names   = ["feed"]
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      subnet_resource_id            = azurerm_subnet.this.id
    }
  }
  diagnostic_settings = {
    // This is the default diagnostic setting
    default = {
      name                  = "default"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workappgrassoc" {
  workspace_id         = module.workspace.workspace_id
  application_group_id = azurerm_virtual_desktop_application_group.this.id
}
