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

variable "tags" {
  type        = map(string)
  default     = { "Owner.Email" : "name@microsoft.com" }
  description = "A map of tags to add to all resources"
}

variable "virtual_desktop_workspace_friendly_name" {
  type        = string
  default     = "Workspace friendly name"
  description = "A friendly name for the Virtual Desktop Workspace. It can be null or a string between 1 and 64 characters long."
}

variable "virtual_desktop_workspace_name" {
  type        = string
  default     = "vdws-avd-001"
  description = "(Required) The name of the Virtual Desktop Workspace. Changing this forces a new resource to be created."
  nullable    = false
}
