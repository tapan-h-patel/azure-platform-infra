variable "resource_group_name" {
  description = "Existing resource group for runner network resources."
  type        = string
}
variable "location" {
  description = "Azure region; must match the Container Apps environment."
  type        = string
}
variable "name" {
  description = "Stable resource naming stem, e.g. azlab-lab-uks-001."
  type        = string
}
variable "address_space" {
  description = "IPv4 CIDR for the new runner VNet. Confirm it does not overlap connected networks."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.address_space))
    error_message = "Provide an IPv4 CIDR."
  }
}
variable "container_apps_subnet_cidr" {
  description = "Dedicated delegated IPv4 subnet, /27 or larger, inside the VNet."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.container_apps_subnet_cidr)) && try(tonumber(split("/", var.container_apps_subnet_cidr)[1]) <= 27, false)
    error_message = "Use an IPv4 subnet of /27 or larger."
  }
}
variable "private_endpoints_subnet_cidr" {
  description = "Separate nondelegated subnet for private endpoints. Must not overlap the Container Apps subnet."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.private_endpoints_subnet_cidr))
    error_message = "Provide an IPv4 CIDR."
  }
}
variable "state_storage_account_id" {
  description = "Existing Terraform state storage account resource ID. Its public access configuration is not changed."
  type        = string
  validation {
    condition     = can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+$", var.state_storage_account_id))
    error_message = "Provide the full storage account resource ID."
  }
}
variable "tags" {
  description = "Caller-provided resource tags."
  type        = map(string)
  default     = {}
}
