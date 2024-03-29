variable "appgroupname" {
  type        = string
  default     = "appgroup-1"
  description = "The name of the application group"
}

variable "description" {
  type        = string
  default     = "This is a AVD workspace."
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

variable "host_pool" {
  type        = string
  default     = "avdhostpool"
  description = "The name of the AVD Host Pool to assign the application group to."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "The location of the AVD Host Pool."
}

variable "name" {
  type        = string
  default     = "workspace-1"
  description = "The name of the AVD Workspace."

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

variable "type" {
  type        = string
  default     = "Desktop"
  description = "The type of the application group"
}

variable "user_group_name" {
  type        = string
  default     = "avdusersgrp"
  description = "Microsoft Entra ID User Group for AVD users"
}
