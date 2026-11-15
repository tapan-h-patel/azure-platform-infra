variable "name" {
  description = "Resource group name supplied by the caller's naming convention."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 90
    error_message = "Provide a nonblank resource group name of at most 90 characters."
  }
}
variable "location" {
  description = "Azure location for resource group metadata."
  type        = string
  nullable    = false
}
variable "tags" {
  description = "Caller-supplied resource group tags."
  type        = map(string)
  default     = {}
}
