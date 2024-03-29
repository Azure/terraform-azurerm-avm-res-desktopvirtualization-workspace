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
