variable "alias" {
  description = "Stable tenant billing alias, distinct from the subscription display name. Changing it can replace subscription ownership."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,62}$", var.alias))
    error_message = "Use a stable alias of 3-63 lowercase letters, digits or hyphens, starting with a letter."
  }
}
variable "subscription_name" {
  description = "Subscription display name following the customer naming convention."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.subscription_name)) > 0 && length(var.subscription_name) <= 64
    error_message = "Use a nonblank subscription display name of at most 64 characters."
  }
}
variable "billing_scope_id" {
  description = "Existing EA enrollment account, MCA invoice section, or MPA customer billing scope ID. The operator must have subscription-creation permission there."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/providers/Microsoft[.]Billing/billingAccounts/[^/]+/(enrollmentAccounts/[^/]+|billingProfiles/[^/]+/invoiceSections/[^/]+|customers/[^/]+)$", var.billing_scope_id)) && !strcontains(var.billing_scope_id, "<") && !strcontains(var.billing_scope_id, ">")
    error_message = "Supply a real EA enrollment account, MCA invoice section or MPA customer billing resource ID; replace all placeholders."
  }
}
variable "management_group_id" {
  description = "Full existing target management group resource ID."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/providers/Microsoft[.]Management/managementGroups/[^/]+$", var.management_group_id))
    error_message = "Supply /providers/Microsoft.Management/managementGroups/<group-name>."
  }
}
variable "workload" {
  description = "Billing workload classification: Production or DevTest (requires offer eligibility)."
  type        = string
  nullable    = false
  validation {
    condition     = contains(["Production", "DevTest"], var.workload)
    error_message = "Choose Production or DevTest, subject to billing offer eligibility."
  }
}
variable "expected_tenant_id" {
  description = "Expected subscription tenant UUID; creation must stay in the configured customer tenant."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.expected_tenant_id))
    error_message = "Supply an expected tenant UUID."
  }
}
variable "tags" {
  description = "Complete subscription tags supplied by the deployment caller."
  type        = map(string)
  nullable    = false
}
