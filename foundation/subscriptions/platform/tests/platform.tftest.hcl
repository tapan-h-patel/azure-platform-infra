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
  subscription_tenant_id = "00000000-0000-0000-0000-000000000000"
  # Replace identifiers and billing scopes before planning. These are not credentials.
  tenant_id                  = "00000000-0000-0000-0000-000000000000"
  deployment_subscription_id = "00000000-0000-0000-0000-000000000000"
  subscriptions = {
    connectivity = {
      alias               = "sub-example-connectivity-shared-001"
      subscription_name   = "sub-example-connectivity-shared-001"
      billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
      management_group_id = "/providers/Microsoft.Management/managementGroups/mg-example-connectivity"
      workload            = "Production"
      tags                = { workload = "connectivity", environment = "shared", managed_by = "terraform", repository = "azure-platform-infra", owner = "platform-team" }
    }

    identity = {
      alias               = "sub-example-identity-shared-001"
      subscription_name   = "sub-example-identity-shared-001"
      billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
      management_group_id = "/providers/Microsoft.Management/managementGroups/mg-example-identity"
      workload            = "Production"
      tags                = { workload = "identity", environment = "shared", managed_by = "terraform", repository = "azure-platform-infra", owner = "platform-team" }
    }

    management = {
      alias               = "sub-example-management-shared-001"
      subscription_name   = "sub-example-management-shared-001"
      billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
      management_group_id = "/providers/Microsoft.Management/managementGroups/mg-example-management"
      workload            = "Production"
      tags                = { workload = "management", environment = "shared", managed_by = "terraform", repository = "azure-platform-infra", owner = "platform-team" }
    }

    observability = {
      alias               = "sub-example-observability-shared-001"
      subscription_name   = "sub-example-observability-shared-001"
      billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
      management_group_id = "/providers/Microsoft.Management/managementGroups/mg-example-observability"
      workload            = "Production"
      tags                = { workload = "observability", environment = "shared", managed_by = "terraform", repository = "azure-platform-infra", owner = "platform-team" }
    }

    security = {
      alias               = "sub-example-security-shared-001"
      subscription_name   = "sub-example-security-shared-001"
      billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
      management_group_id = "/providers/Microsoft.Management/managementGroups/mg-example-security"
      workload            = "Production"
      tags                = { workload = "security", environment = "shared", managed_by = "terraform", repository = "azure-platform-infra", owner = "platform-team" }
    }
  }


}
run "all_five_platform_areas" {
  command = plan
  assert {
    condition     = length(output.subscriptions) == 5 && alltrue([for area, subscription in output.subscriptions : subscription.management_group_id == var.subscriptions[area].management_group_id])
    error_message = "All five platform areas must retain their explicitly requested management group placement."
  }
}
run "reject_duplicate_aliases" {
  command = plan
  variables {
    subscriptions = {
      first = {
        alias               = "sub-duplicate"
        subscription_name   = "sub-test-first-shared-001"
        billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
        management_group_id = "/providers/Microsoft.Management/managementGroups/mg-test-management"
        workload            = "Production"
        tags                = {}
      }
      second = {
        alias               = "sub-duplicate"
        subscription_name   = "sub-test-second-shared-001"
        billing_scope_id    = "/providers/Microsoft.Billing/billingAccounts/test-account/enrollmentAccounts/test-enrollment"
        management_group_id = "/providers/Microsoft.Management/managementGroups/mg-test-security"
        workload            = "Production"
        tags                = {}
      }
    }
  }
  expect_failures = [var.subscriptions]
}
