variable "scope" {
  description = "Full Azure RBAC scope resource ID."
  type        = string
  nullable    = false
}
variable "scope_name" {
  description = "Customer-configured unique naming token for the scope, e.g. platform."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,79}$", var.scope_name))
    error_message = "Use 1-80 lowercase letters, digits, or hyphens for scope_name."
  }
}
variable "scope_type" {
  description = "Scope naming token (mg, sub, rg, or resource)."
  type        = string
  validation {
    condition     = contains(["mg", "sub", "rg", "resource"], var.scope_type)
    error_message = "Use mg, sub, rg, or resource."
  }
}
variable "group_owner_object_ids" {
  description = "Explicit group owner user/service principal object IDs. Ownership permits membership administration, so treat these identities as privileged."
  type        = set(string)
  nullable    = false
  validation {
    condition     = length(var.group_owner_object_ids) > 0 && alltrue([for id in var.group_owner_object_ids : can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", id))])
    error_message = "Supply at least one valid group owner object UUID."
  }
}
variable "roles" {
  description = "Role-name suffix to built-in Azure role mapping. Defaults create the three agreed access groups. Empty disables access group creation."
  type        = map(string)
  default = {
    reader      = "Reader"
    contributor = "Contributor"
    owner       = "Owner"
  }
  nullable = false
  validation {
    condition     = alltrue([for key, value in var.roles : can(regex("^[a-z0-9][a-z0-9-]{0,39}$", key)) && length(trimspace(value)) > 0])
    error_message = "Role keys must be lowercase naming tokens and role names must be nonblank."
  }
}
