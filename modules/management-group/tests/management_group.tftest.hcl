mock_provider "azurerm" {}

variables {
  name                       = "mg-example-platform"
  display_name               = "Example Platform"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/example-root"
}

run "group_without_subscription_moves" {
  command = plan

  assert {
    condition     = azurerm_management_group.management_group.parent_management_group_id == var.parent_management_group_id
    error_message = "The caller's explicit parent must be used."
  }
  assert {
    condition     = length(azurerm_management_group_subscription_association.subscription_association) == 0
    error_message = "Default usage must not move subscriptions."
  }
  assert {
    condition     = azurerm_management_group.management_group.name == var.name && azurerm_management_group.management_group.display_name == var.display_name
    error_message = "The caller's stable name and display name must be used."
  }
}

run "explicit_subscription_associations" {
  command = plan

  variables {
    subscription_ids = ["11111111-1111-1111-1111-111111111111"]
  }

  assert {
    condition     = azurerm_management_group_subscription_association.subscription_association["11111111-1111-1111-1111-111111111111"].subscription_id == "/subscriptions/11111111-1111-1111-1111-111111111111"
    error_message = "Subscription UUIDs must become full Azure subscription resource IDs."
  }
}

run "reject_short_parent_name" {
  command = plan
  variables {
    parent_management_group_id = "example-root"
  }
  expect_failures = [var.parent_management_group_id]
}

run "reject_subscription_resource_id_input" {
  command = plan
  variables {
    subscription_ids = ["/subscriptions/11111111-1111-1111-1111-111111111111"]
  }
  expect_failures = [var.subscription_ids]
}
