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

# This picks a random region from the list of regions.
resource "random_integer" "region_index" {
  min = 0
  max = length(local.azure_regions) - 1
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = local.azure_regions[random_integer.region_index.result]
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                = var.host_pool
  resource_group_name = var.resource_group_name
  location            = var.location
  load_balancer_type  = var.type
  type                = "Pooled"
}

resource "azurerm_virtual_desktop_application_group" "this" {
  name                = var.appgroupname
  resource_group_name = var.resource_group_name
  location            = var.location
  host_pool_id        = data.azurerm_virtual_desktop_host_pool.this.id
  type                = var.type
}

# This is the module call
module "workspace" {
  source              = "../../"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name
  description         = var.description
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workappgrassoc" {
  workspace_id         = module.workspace.workspace_id
  application_group_id = azurerm_virtual_desktop_application_group.this.id
}
