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
  description = "The name of the AVD Host Pool."
  default     = "workspace-1"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

variable "description" {
  type        = string
  description = "The description of the AVD Workspace."
  default     = "This is a AVD workspace."
}

variable "appgroupname" {
  description = "The name of the application group"
  default     = "appgroup-1"
  type        = string
}

variable "type" {
  description = "The type of the application group"
  default     = "Desktop"
  type        = string
}

variable "host_pool" {
  type        = string
  default     = "avdhostpool"
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
