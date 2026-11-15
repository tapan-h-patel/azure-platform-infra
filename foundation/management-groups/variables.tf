variable "tenant_id" {
  description = "Customer Entra tenant UUID."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "Provide a tenant UUID."
  }
}
variable "subscription_id" {
  description = "AzureRM authentication subscription UUID; this root does not move it."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "Provide a subscription UUID."
  }
}
variable "group_owner_object_ids" {
  description = "Group owner user/SP object IDs; ownership controls membership and is privileged. Include the deployment identity where required by directory permissions."
  type        = set(string)
}
variable "roles" {
  description = "Role suffix to Azure role mapping for every scope; configurable for customer policy."
  type        = map(string)
}
variable "root_management_group" {
  description = "New intermediate root below the existing Tenant Root."
  type        = object({ name = string, display_name = string, access_name = string })
}
variable "branch_management_groups" {
  description = "Direct children of intermediate root (Platform and Workloads in the example)."
  type        = map(object({ name = string, display_name = string, access_name = string }))
}
variable "leaf_management_groups" {
  description = "Children of a configured branch; parent_key is a branch map key."
  type        = map(object({ name = string, display_name = string, access_name = string, parent_key = string }))
  validation {
    condition     = alltrue([for group in values(var.leaf_management_groups) : contains(keys(var.branch_management_groups), group.parent_key)])
    error_message = "Every leaf parent_key must refer to an existing branch key."
  }
  validation {
    condition     = length(distinct(concat([var.root_management_group.name], [for group in values(var.branch_management_groups) : group.name], [for group in values(var.leaf_management_groups) : group.name]))) == 1 + length(var.branch_management_groups) + length(var.leaf_management_groups)
    error_message = "Management group names must be unique across all levels."
  }
  validation {
    condition     = length(distinct(concat([var.root_management_group.access_name], [for group in values(var.branch_management_groups) : group.access_name], [for group in values(var.leaf_management_groups) : group.access_name]))) == 1 + length(var.branch_management_groups) + length(var.leaf_management_groups)
    error_message = "Access naming tokens must be unique across all scopes."
  }
}

variable "parent_management_group_id" {
  description = "Full existing parent management group ID supplied in terraform.tfvars; normally the Tenant Root."
  type        = string
  validation {
    condition     = can(regex("(?i)^/providers/Microsoft[.]Management/managementGroups/[^/]+$", var.parent_management_group_id))
    error_message = "Provide a full parent management group resource ID."
  }
}
