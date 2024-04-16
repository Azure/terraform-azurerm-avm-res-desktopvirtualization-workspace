terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.44.1, < 3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, <4.0.0"
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
  max = length(local.azure_regions) - 1
  min = 0
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

module "avm_res_desktopvirtualization_hostpool" {
  source                                        = "Azure/avm-res-desktopvirtualization-hostpool/azurerm"
  version                                       = "0.1.4"
  virtual_desktop_host_pool_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_host_pool_name                = var.host_pool
  virtual_desktop_host_pool_location            = azurerm_resource_group.this.location
  virtual_desktop_host_pool_load_balancer_type  = "BreadthFirst"
  virtual_desktop_host_pool_type                = "Pooled"
  resource_group_name                           = azurerm_resource_group.this.name
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
}

# Get an existing built-in role definition
data "azurerm_role_definition" "this" {
  name = "Desktop Virtualization User"
}

# Get an existing Azure AD group that will be assigned to the application group
data "azuread_group" "existing" {
  display_name     = var.user_group_name
  security_enabled = true
}

# Assign the Azure AD group to the application group
resource "azurerm_role_assignment" "this" {
  principal_id                     = data.azuread_group.existing.object_id
  scope                            = module.avm-res-desktopvirtualization-applicationgroup.resource.id
  role_definition_id               = data.azurerm_role_definition.this.id
  skip_service_principal_aad_check = false
}

module "avm-res-desktopvirtualization-applicationgroup" {
  source                                                = "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm"
  version                                               = "0.1.2"
  virtual_desktop_application_group_name                = var.name
  virtual_desktop_application_group_type                = var.type
  virtual_desktop_application_group_host_pool_id        = module.avm_res_desktopvirtualization_hostpool.resource.id
  virtual_desktop_application_group_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_application_group_location            = azurerm_resource_group.this.location
  user_group_name                                       = "avdusersgrp"
}

# This is the module call
module "workspace" {
  source              = "../../"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
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
  application_group_id = module.avm-res-desktopvirtualization-applicationgroup.resource.id
  workspace_id         = module.workspace.resource.id
}
