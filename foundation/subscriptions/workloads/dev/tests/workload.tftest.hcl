mock_provider "azurerm" {
  mock_resource "azurerm_subscription" {
    override_during = plan
    defaults = {
      subscription_id = "22222222-2222-2222-2222-222222222222"
      tenant_id       = "00000000-0000-0000-0000-000000000000"
    }
  }
}
variables {
  # Dedicated dev workload subscription root. Replace customer and billing inputs.
  tenant_id                  = "00000000-0000-0000-0000-000000000000"
  deployment_subscription_id = "00000000-0000-0000-0000-000000000000"
  subscription_tenant_id     = "00000000-0000-0000-0000-000000000000"
  subscriptions = {
    workloads = {
      alias               = "sub-example-workloads-dev-001"
      subscription_name   = "sub-example-workloads-dev-001"
      billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
      management_group_id = "/providers/Microsoft.Management/managementGroups/mg-example-dev"
      workload            = "Production"
      tags                = { workload = "workloads", environment = "dev", managed_by = "terraform", repository = "azure-platform-infra", owner = "platform-team" }
    }
  }
}
run "workload_placement" {
  command = plan
  assert {
    condition     = length(output.subscriptions) == 1 && output.subscriptions["workloads"].management_group_id == "/providers/Microsoft.Management/managementGroups/mg-example-dev" && output.subscriptions["workloads"].subscription_name == "sub-example-workloads-dev-001"
    error_message = "The workload root must create only its configured dev subscription in its matching management group."
  }
}
