variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "name" {
  type        = string
  description = "The name of the AVD Workspace."
  default     = "workspace-3"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

variable "description" {
  type        = string
  description = "The description of the AVD Workspace."
  default     = "AVD Workspace for all your Azure Virtual Desktop deployment."
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether or not public network access is enabled for the AVD Workspace."
  default     = false
}

variable "resource_group_name" {
  type        = string
  default     = "rg-avm-test"
  description = "The resource group where the AVD Workspace is deployed."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "The location of the AVD Workspace."

}
