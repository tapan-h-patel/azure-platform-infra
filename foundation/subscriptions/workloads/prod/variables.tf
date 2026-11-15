variable "tenant_id" {
  description = "Provider authentication/home tenant UUID for the billing creation identity."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "Supply the customer tenant UUID."
  }
}
variable "deployment_subscription_id" {
  description = "Existing subscription UUID used to initialize AzureRM, not a new subscription to create."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.deployment_subscription_id))
    error_message = "Supply an existing subscription UUID for provider authentication."
  }
}
variable "subscriptions" {
  description = "Subscriptions keyed by stable platform area; every value is supplied through terraform.tfvars."
  type = map(object({
    alias               = string
    subscription_name   = string
    billing_scope_id    = string
    management_group_id = string
    workload            = string
    tags                = map(string)
  }))
  nullable = false
  validation {
    condition     = length(var.subscriptions) > 0 && length(distinct([for subscription in values(var.subscriptions) : subscription.alias])) == length(var.subscriptions)
    error_message = "Provide at least one subscription with a unique alias for every entry."
  }
  validation {
    condition     = length(distinct([for subscription in values(var.subscriptions) : subscription.subscription_name])) == length(var.subscriptions)
    error_message = "Use distinct display names so subscriptions can be identified clearly."
  }
}

variable "subscription_tenant_id" {
  description = "Expected tenant UUID of newly created subscriptions; may differ from the provider home tenant for eligible partner arrangements."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_tenant_id))
    error_message = "Supply the expected subscription tenant UUID."
  }
}
