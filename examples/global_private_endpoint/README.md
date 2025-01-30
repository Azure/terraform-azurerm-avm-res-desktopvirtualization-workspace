<!-- BEGIN_TF_DOCS -->
# Global private endpoint example

This deploys the module for Azure Virtual Desktop initial feed discovery private endpoint. Workspace feed requests are denied from public routes. Workspace feed requests are allowed from private routes.
Only one for all your Azure Virtual Desktop deployment. Public access is disabled. Refer to [Supported scenaios](https://learn.microsoft.com/en-us/azure/virtual-desktop/private-link-overview) for furhter details.

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"
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
  virtual_desktop_workspace_location            = azurerm_resource_group.this.location
  virtual_desktop_workspace_description         = var.description
  virtual_desktop_workspace_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_workspace_name                = var.virtual_desktop_workspace_name
  virtual_desktop_workspace_friendly_name       = var.virtual_desktop_workspace_friendly_name
  public_network_access_enabled                 = false
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
}

module "avm_res_network_privateendpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.1.0"
  enable_telemetry               = var.enable_telemetry # see variables.tf
  name                           = module.naming.private_endpoint.name_unique
  location                       = azurerm_resource_group.this.location
  resource_group_name            = azurerm_resource_group.this.name
  network_interface_name         = module.naming.network_interface.name_unique
  private_connection_resource_id = module.workspace.resource.id
  subnet_resource_id             = azurerm_subnet.this.id
  subresource_names              = ["global"]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71, < 5.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.6.0, <4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: The description of the AVD Workspace.

Type: `string`

Default: `"AVD Workspace for all your Azure Virtual Desktop deployment."`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_virtual_desktop_workspace_friendly_name"></a> [virtual\_desktop\_workspace\_friendly\_name](#input\_virtual\_desktop\_workspace\_friendly\_name)

Description: A friendly name for the Virtual Desktop Workspace. It can be null or a string between 1 and 64 characters long.

Type: `string`

Default: `"Workspace friendly name"`

### <a name="input_virtual_desktop_workspace_name"></a> [virtual\_desktop\_workspace\_name](#input\_virtual\_desktop\_workspace\_name)

Description: (Required) The name of the Virtual Desktop Workspace. Changing this forces a new resource to be created.

Type: `string`

Default: `"vdws-avd-001"`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_res_network_privateendpoint"></a> [avm\_res\_network\_privateendpoint](#module\_avm\_res\_network\_privateendpoint)

Source: Azure/avm-res-network-privateendpoint/azurerm

Version: 0.1.0

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.3.0

### <a name="module_workspace"></a> [workspace](#module\_workspace)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->