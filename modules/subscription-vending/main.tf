resource "azurerm_subscription" "subscription" {
  alias             = var.alias
  subscription_name = var.subscription_name
  billing_scope_id  = var.billing_scope_id
  workload          = var.workload
  tags              = var.tags

  lifecycle {
    prevent_destroy = true
    postcondition {
      condition     = lower(self.tenant_id) == lower(var.expected_tenant_id)
      error_message = "The created subscription is not in the expected tenant. Stop and resolve billing/tenant ownership before proceeding."
    }
  }
}

resource "azurerm_management_group_subscription_association" "subscription_association" {
  management_group_id = var.management_group_id
  subscription_id     = "/subscriptions/${azurerm_subscription.subscription.subscription_id}"
}
