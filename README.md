<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-desktopvirtualization-workspace

[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/Azure/terraform-azurerm-avm-res-desktopvirtualization-workspace.svg)](http://isitmaintained.com/project/Azure/terraform-azurerm-avm-res-desktopvirtualization-workspace "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/Azure/terraform-azurerm-avm-res-desktopvirtualization-workspace.svg)](http://isitmaintained.com/project/Azure/terraform-azurerm-avm-res-desktopvirtualization-workspace "Percentage of issues still open")

Module to deploy Azure Virtual Desktop Workspace in Azure.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.6.6, < 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71, < 5.0.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.6.0, <4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_virtual_desktop_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_virtual_desktop_workspace_location"></a> [virtual\_desktop\_workspace\_location](#input\_virtual\_desktop\_workspace\_location)

Description: (Required) The location/region where the Virtual Desktop Workspace is located. Changing the location/region forces a new resource to be created.

Type: `string`

### <a name="input_virtual_desktop_workspace_name"></a> [virtual\_desktop\_workspace\_name](#input\_virtual\_desktop\_workspace\_name)

Description: (Required) The name of the Virtual Desktop Workspace. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_virtual_desktop_workspace_resource_group_name"></a> [virtual\_desktop\_workspace\_resource\_group\_name](#input\_virtual\_desktop\_workspace\_resource\_group\_name)

Description: (Required) The name of the resource group in which to create the Virtual Desktop Workspace. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetry.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_lock"></a> [lock](#input\_lock)

Description:   Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: (Optional) Whether public network access is allowed for this Virtual Desktop Workspace. Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled)

Description: Whether enable tracing tags that generated by BridgeCrew Yor.

Type: `bool`

Default: `false`

### <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix)

Description: Default prefix for generated tracing tags

Type: `string`

Default: `"avm_"`

### <a name="input_virtual_desktop_workspace_description"></a> [virtual\_desktop\_workspace\_description](#input\_virtual\_desktop\_workspace\_description)

Description: (Optional) A description for the Virtual Desktop Workspace.

Type: `string`

Default: `null`

### <a name="input_virtual_desktop_workspace_friendly_name"></a> [virtual\_desktop\_workspace\_friendly\_name](#input\_virtual\_desktop\_workspace\_friendly\_name)

Description: (Optional) A friendly name for the Virtual Desktop Workspace. It can be null or a string between 1 and 64 characters long.

Type: `string`

Default: `null`

### <a name="input_virtual_desktop_workspace_tags"></a> [virtual\_desktop\_workspace\_tags](#input\_virtual\_desktop\_workspace\_tags)

Description: (Optional) A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `null`

### <a name="input_virtual_desktop_workspace_timeouts"></a> [virtual\_desktop\_workspace\_timeouts](#input\_virtual\_desktop\_workspace\_timeouts)

Description: - `create` - (Defaults to 60 minutes) Used when creating the Virtual Desktop Workspace.
- `delete` - (Defaults to 60 minutes) Used when deleting the Virtual Desktop Workspace.
- `read` - (Defaults to 5 minutes) Used when retrieving the Virtual Desktop Workspace.
- `update` - (Defaults to 60 minutes) Used when updating the Virtual Desktop Workspace.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This output is the full output for the resource to allow flexibility to reference all possible values for the resource. Example usage: module.<modulename>.resource.id

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This output is the full output for the resource to allow flexibility to reference all possible values for the resource. Example usage: module.<modulename>.resource.id

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->