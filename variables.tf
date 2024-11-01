# Define variables for the AVD Host Pool deployment
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the resources will be deployed."
}

variable "virtual_desktop_workspace_location" {
  type        = string
  description = "(Required) The location/region where the Virtual Desktop Workspace is located. Changing the location/region forces a new resource to be created."
  nullable    = false
}

variable "virtual_desktop_workspace_name" {
  type        = string
  description = "(Required) The name of the Virtual Desktop Workspace. Changing this forces a new resource to be created."
  nullable    = false
}

variable "virtual_desktop_workspace_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Virtual Desktop Workspace. Changing this forces a new resource to be created."
  nullable    = false
}

variable "diagnostic_settings" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetry.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# tflint-ignore: terraform_unused_declarations
variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    subresource_names                       = optional(list(string))
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - The service name of the private endpoint.  Possible value are `blob`, 'dfs', 'file', `queue`, `table`, and `web`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
DESCRIPTION
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether public network access is allowed for this Virtual Desktop Workspace. Defaults to `true`."
}

variable "subresource_name" {
  type        = list(string)
  default     = []
  description = "The names of the subresources to assosciatied with the private endpoint. The target subresource must be one of: 'feed', or 'global'."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

# tflint-ignore: terraform_unused_declarations
variable "tracing_tags_enabled" {
  type        = bool
  default     = false
  description = "Whether enable tracing tags that generated by BridgeCrew Yor."
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tracing_tags_prefix" {
  type        = string
  default     = "avm_"
  description = "Default prefix for generated tracing tags"
  nullable    = false
}

variable "virtual_desktop_workspace_description" {
  type        = string
  default     = null
  description = "(Optional) A description for the Virtual Desktop Workspace."
}

variable "virtual_desktop_workspace_friendly_name" {
  type        = string
  default     = null
  description = "(Optional) A friendly name for the Virtual Desktop Workspace. It can be null or a string between 1 and 64 characters long."

  validation {
    condition     = var.virtual_desktop_workspace_friendly_name == null || can(regex("^.{1,64}$", var.virtual_desktop_workspace_friendly_name))
    error_message = "The friendly name must be null or a string between 1 and 64 characters long."
  }
}

variable "virtual_desktop_workspace_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "virtual_desktop_workspace_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 60 minutes) Used when creating the Virtual Desktop Workspace.
 - `delete` - (Defaults to 60 minutes) Used when deleting the Virtual Desktop Workspace.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Virtual Desktop Workspace.
 - `update` - (Defaults to 60 minutes) Used when updating the Virtual Desktop Workspace.
EOT
}
