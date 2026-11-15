variable "name" {
  description = "Stable management group ID, unique within the tenant. Changing it replaces the group."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,89}$", var.name))
    error_message = "Use 1-90 lowercase letters, digits, or hyphens, starting with a letter or digit."
  }
}

variable "display_name" {
  description = "Human-readable display name; defaults to name when omitted."
  type        = string
  default     = null
  validation {
    condition     = var.display_name == null ? true : length(trimspace(var.display_name)) > 0 && length(var.display_name) <= 90
    error_message = "If provided, display_name must be nonblank and at most 90 characters."
  }
}

variable "parent_management_group_id" {
  description = "Explicit parent resource ID, including the tenant root ID when creating a top-level group."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/providers/Microsoft\\.Management/managementGroups/[^/]+$", var.parent_management_group_id))
    error_message = "Provide the full parent resource ID: /providers/Microsoft.Management/managementGroups/<parent-name>."
  }
}

variable "subscription_ids" {
  description = "Optional subscription UUIDs to associate with this group. Empty creates no associations and does not manage other subscriptions."
  type        = set(string)
  default     = []
  nullable    = false
  validation {
    condition = alltrue([
      for id in var.subscription_ids :
      can(regex("^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$", id))
    ])
    error_message = "Use lowercase subscription UUIDs, not /subscriptions/... resource IDs."
  }
}
