variable "name" {
  description = "Container Apps environment name."
  type        = string
}
variable "resource_group_name" {
  description = "Existing runner environment resource group."
  type        = string
}
variable "location" {
  description = "Azure location matching the infrastructure subnet."
  type        = string
}
variable "infrastructure_subnet_id" {
  description = "Dedicated subnet delegated to Microsoft.App/environments, /27 or larger."
  type        = string
  validation {
    condition     = can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.infrastructure_subnet_id))
    error_message = "Provide the full infrastructure subnet resource ID."
  }
}
variable "tags" {
  description = "Caller-supplied tags."
  type        = map(string)
  default     = {}
}
