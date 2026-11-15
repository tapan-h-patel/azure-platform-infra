variable "tenant_id" {
  description = "Customer Entra tenant ID."
  type        = string
}
variable "subscription_id" {
  description = "Target infrastructure subscription ID."
  type        = string
}
variable "location" {
  description = "Azure location."
  type        = string
}
variable "name" {
  description = "Stable naming stem, e.g. azlab-lab-uks-001."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,39}$", var.name))
    error_message = "Use 3-40 lowercase letters, digits and hyphens, starting with a letter."
  }
}
variable "tags" {
  description = "Complete resource tags supplied in terraform.tfvars, including managed_by and repository."
  type        = map(string)
}
variable "address_space" {
  description = "Runner VNet IPv4 CIDR. Check overlap before use."
  type        = string
}
variable "container_apps_subnet_cidr" {
  description = "Dedicated /27 or larger delegated runner subnet."
  type        = string
}
variable "private_endpoints_subnet_cidr" {
  description = "Separate private endpoint subnet."
  type        = string
}
variable "state_storage_account_id" {
  description = "Full existing state storage resource ID."
  type        = string
}

variable "resource_group_name" {
  description = "Explicit resource group name from deployment configuration."
  type        = string
}
