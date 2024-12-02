terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, <4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This picks a random region from the list of regions.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# This is required for resource modules

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# A vnet is required for the private endpoint.
resource "azurerm_virtual_network" "this" {
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink-global.wvd.microsoft.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "global-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# This is the module call
module "workspace" {
  source                                        = "../../"
  enable_telemetry                              = var.enable_telemetry
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_desktop_workspace_location            = azurerm_resource_group.this.location
  virtual_desktop_workspace_description         = var.description
  virtual_desktop_workspace_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_workspace_name                = var.virtual_desktop_workspace_name
  virtual_desktop_workspace_friendly_name       = var.virtual_desktop_workspace_friendly_name
  tags                                          = var.tags
  public_network_access_enabled                 = false
  private_endpoints = {
    primary = {
      name                            = "pe-${var.virtual_desktop_workspace_name}"
      private_service_connection_name = "psc-${var.virtual_desktop_workspace_name}"
      network_interface_name          = "nic-pe-${var.virtual_desktop_workspace_name}"
      private_connection_resource_id  = module.workspace.resource.id
      subresource_name                = ["global"]
      private_dns_zone_ids            = [azurerm_private_dns_zone.this.id]
      subnet_resource_id              = azurerm_subnet.this.id
      subresource_names               = ["global"]
    }
  }
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
}
