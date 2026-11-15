mock_provider "azurerm" {
  mock_resource "azurerm_subscription" {
    override_during = plan
    defaults = {
      subscription_id = "22222222-2222-2222-2222-222222222222"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
      id              = "/providers/Microsoft.Subscription/aliases/sub-test-management-shared-001"
    }
  }
}
variables {
  alias               = "sub-test-management-shared-001"
  subscription_name   = "sub-test-management-shared-001"
  billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
  management_group_id = "/providers/Microsoft.Management/managementGroups/mg-test-management"
  expected_tenant_id  = "11111111-1111-1111-1111-111111111111"
  workload            = "Production"
  tags                = { workload = "management", environment = "shared", managed_by = "terraform" }
}
run "ea_creation_and_placement" {
  command = plan
  assert {
    condition     = azurerm_management_group_subscription_association.subscription_association.subscription_id == "/subscriptions/22222222-2222-2222-2222-222222222222" && azurerm_management_group_subscription_association.subscription_association.management_group_id == var.management_group_id
    error_message = "Associate the new subscription UUID, not the alias resource ID, with the requested group."
  }
  assert {
    condition     = azurerm_subscription.subscription.billing_scope_id == var.billing_scope_id && azurerm_subscription.subscription.workload == var.workload && azurerm_subscription.subscription.tags == var.tags
    error_message = "Preserve caller billing, workload and tag inputs."
  }
}
run "mca_billing_scope" {
  command = plan
  variables {
    billing_scope_id = "/providers/Microsoft.Billing/billingAccounts/test-account/billingProfiles/test-profile/invoiceSections/test-section"
  }
}
run "mpa_billing_scope" {
  command = plan
  variables {
    billing_scope_id = "/providers/Microsoft.Billing/billingAccounts/test-account/customers/test-customer"
  }
}
run "reject_missing_billing" {
  command = plan
  variables { billing_scope_id = "" }
  expect_failures = [var.billing_scope_id]
}
run "reject_wrong_tenant" {
  command = plan
  variables { expected_tenant_id = "33333333-3333-3333-3333-333333333333" }
  expect_failures = [azurerm_subscription.subscription]
}
run "reject_invalid_workload" {
  command = plan
  variables { workload = "FreeTrial" }
  expect_failures = [var.workload]
}
