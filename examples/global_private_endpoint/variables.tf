variable "description" {
  type        = string
  default     = "AVD Workspace for all your Azure Virtual Desktop deployment."
  description = "The description of the AVD Workspace."
}

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
  default     = "globalprivate-empty"
  description = "The name of the AVD Workspace."

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether or not public network access is enabled for the AVD Workspace."
}

variable "virtual_desktop_workspace_friendly_name" {
  type        = string
  default     = "Workspace friendly name"
  description = "A friendly name for the Virtual Desktop Workspace. It can be null or a string between 1 and 64 characters long."

  validation {
    condition     = var.virtual_desktop_workspace_friendly_name == null || can(regex("^.{1,64}$", var.virtual_desktop_workspace_friendly_name))
    error_message = "The friendly name must be null or a string between 1 and 64 characters long."
  }
}

variable "virtual_desktop_workspace_name" {
  type        = string
  default     = "vdws-avd-001"
  description = "(Required) The name of the Virtual Desktop Workspace. Changing this forces a new resource to be created."
  nullable    = false
}
