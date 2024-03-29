<!-- BEGIN_TF_DOCS -->
# Feed private endpoint example

This deploys the module with the feed private endpoint and public access disabled. One per workspace.

```hcl
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

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                = var.host_pool
  resource_group_name = var.resource_group_name
  location            = var.location
  load_balancer_type  = "BreadthFirst" #["BreadthFirst" "DepthFirst"]
  type                = "Pooled"
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
  source                        = "../../"
  enable_telemetry              = var.enable_telemetry
  resource_group_name           = var.resource_group_name
  location                      = var.location
  name                          = var.name
  description                   = var.description
  public_network_access_enabled = var.public_network_access_enabled
  subresource_names             = ["feed"]
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.7.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_desktop_application_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_application_group) (resource)
- [azurerm_virtual_desktop_host_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool) (resource)
- [azurerm_virtual_desktop_workspace_application_group_association.workappgrassoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace_application_group_association) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_appgroupname"></a> [appgroupname](#input\_appgroupname)

Description: The name of the application group

Type: `string`

Default: `"appgroup2"`

### <a name="input_description"></a> [description](#input\_description)

Description: The description of the AVD Workspace.

Type: `string`

Default: `"AVD Workspace with private endpoint"`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_host_pool"></a> [host\_pool](#input\_host\_pool)

Description: The name of the AVD Host Pool to assign the application group to.

Type: `string`

Default: `"avdhostpool2"`

### <a name="input_location"></a> [location](#input\_location)

Description: The location of the AVD Host Pool.

Type: `string`

Default: `"eastus"`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the AVD Workspace.

Type: `string`

Default: `"workspace2"`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Whether or not public network access is enabled for the AVD Workspace.

Type: `bool`

Default: `false`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the AVD Host Pool is deployed.

Type: `string`

Default: `"rg-avm-test"`

### <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names)

Description: The names of the subresources to assosciatied with the private endpoint. The target subresource must be one of: 'feed', or 'global'.

Type: `string`

Default: `"feed"`

## Outputs

No outputs.

## Modules

The following Modules are called:

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