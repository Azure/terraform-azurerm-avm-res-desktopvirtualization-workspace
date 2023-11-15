variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "workspace" {
  type        = string
  description = "The name of the AVD Host Pool."
  default     = "workspace-2"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.workspace))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

variable "subresource_names" {
  type        = string
  default     = "feed"
  description = "The names of the subresources to assosciatied with the private endpoint. The target subresource must be one of: 'feed', or 'global'."
}

variable "appgroupname" {
  description = "The name of the application group"
  default     = "appgroup-2"
  type        = string
}

variable "host_pool" {
  type        = string
  default     = "avdhostpool2"
  description = "The name of the AVD Host Pool to assign the application group to."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-avm-test"
  description = "The resource group where the AVD Host Pool is deployed."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "The location of the AVD Host Pool."
}
