mock_provider "azurerm" {
  mock_resource "azurerm_management_group" {
    defaults = { id = "/providers/Microsoft.Management/managementGroups/mock-group" }
  }
}
mock_provider "azuread" {
  mock_resource "azuread_group" {
    defaults = { object_id = "33333333-3333-3333-3333-333333333333" }
  }
}

override_resource {
  target = module.intermediate_root.module.management_group.azurerm_management_group.management_group
  values = { id = "/providers/Microsoft.Management/managementGroups/test-root" }
}
override_resource {
  target = module.branches["platform"].module.management_group.azurerm_management_group.management_group
  values = { id = "/providers/Microsoft.Management/managementGroups/test-platform" }
}
override_resource {
  target = module.branches["workloads"].module.management_group.azurerm_management_group.management_group
  values = { id = "/providers/Microsoft.Management/managementGroups/test-workloads" }
}
variables {
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/11111111-1111-1111-1111-111111111111"
  roles                      = { reader = "Reader", contributor = "Contributor", owner = "Owner" }
  tenant_id                  = "11111111-1111-1111-1111-111111111111"
  subscription_id            = "22222222-2222-2222-2222-222222222222"
  group_owner_object_ids     = ["44444444-4444-4444-4444-444444444444"]
  root_management_group      = { name = "mg-test-root", display_name = "Root", access_name = "test-root" }
  branch_management_groups = {
    platform  = { name = "mg-test-platform", display_name = "Platform", access_name = "platform" }
    workloads = { name = "mg-test-workloads", display_name = "Workloads", access_name = "workloads" }
  }
  leaf_management_groups = {
    management = { name = "mg-test-management", display_name = "Management", access_name = "management", parent_key = "platform" }
    dev        = { name = "mg-test-dev", display_name = "Dev", access_name = "dev", parent_key = "workloads" }
  }
}
run "hierarchy_and_scoped_groups" {
  command = apply
  assert {
    condition     = module.intermediate_root.parent_management_group_id == "/providers/Microsoft.Management/managementGroups/${var.tenant_id}" && alltrue([for group in module.branches : group.parent_management_group_id == module.intermediate_root.id]) && alltrue([for key, group in module.leaves : group.parent_management_group_id == module.branches[var.leaf_management_groups[key].parent_key].id])
    error_message = "Every hierarchy level must reference the intended parent."
  }
  assert {
    condition     = module.branches["platform"].groups["reader"].display_name == "grp-platform-mg-reader" && length(module.branches["platform"].groups) == 3 && module.leaves["management"].groups["owner"].role_name == "Owner" && module.leaves["management"].groups["owner"].scope == module.leaves["management"].id
    error_message = "Create the three named roles and bind them to their own scope."
  }
}
run "reject_duplicate_names" {
  command = plan
  variables {
    parent_management_group_id = "/providers/Microsoft.Management/managementGroups/11111111-1111-1111-1111-111111111111"
    roles                      = { reader = "Reader", contributor = "Contributor", owner = "Owner" }
    leaf_management_groups     = { duplicate = { name = "mg-test-platform", display_name = "Duplicate", access_name = "duplicate", parent_key = "platform" } }
  }
  expect_failures = [var.leaf_management_groups]
}
run "reject_duplicate_access_names" {
  command = plan
  variables {
    parent_management_group_id = "/providers/Microsoft.Management/managementGroups/11111111-1111-1111-1111-111111111111"
    roles                      = { reader = "Reader", contributor = "Contributor", owner = "Owner" }
    leaf_management_groups     = { duplicate = { name = "mg-test-duplicate", display_name = "Duplicate", access_name = "platform", parent_key = "platform" } }
  }
  expect_failures = [var.leaf_management_groups]
}
