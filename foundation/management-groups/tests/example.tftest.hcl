mock_provider "azurerm" {
  mock_resource "azurerm_management_group" {
    defaults = { id = "/providers/Microsoft.Management/managementGroups/example-group" }
  }
}
mock_provider "azuread" {
  mock_resource "azuread_group" {
    defaults = { object_id = "33333333-3333-3333-3333-333333333333" }
  }
}
variables {
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/11111111-1111-1111-1111-111111111111"
  roles                      = { reader = "Reader", contributor = "Contributor", owner = "Owner" }
  # New-tenant example. Replace IDs and customer naming tokens; do not use live credentials.
  tenant_id              = "00000000-0000-0000-0000-000000000000"
  subscription_id        = "00000000-0000-0000-0000-000000000000"
  group_owner_object_ids = ["00000000-0000-0000-0000-000000000000"]
  root_management_group = {
    name         = "mg-example-root"
    display_name = "Intermediate Root"
    access_name  = "example-root"
  }
  branch_management_groups = {
    platform  = { name = "mg-example-platform", display_name = "Platform", access_name = "platform" }
    workloads = { name = "mg-example-workloads", display_name = "Workloads", access_name = "workloads" }
  }
  leaf_management_groups = {
    connectivity  = { name = "mg-example-connectivity", display_name = "Connectivity", access_name = "connectivity", parent_key = "platform" }
    identity      = { name = "mg-example-identity", display_name = "Identity", access_name = "identity", parent_key = "platform" }
    management    = { name = "mg-example-management", display_name = "Management", access_name = "management", parent_key = "platform" }
    observability = { name = "mg-example-observability", display_name = "Observability", access_name = "observability", parent_key = "platform" }
    security      = { name = "mg-example-security", display_name = "Security", access_name = "security", parent_key = "platform" }
    dev           = { name = "mg-example-dev", display_name = "Dev", access_name = "dev", parent_key = "workloads" }
    prod          = { name = "mg-example-prod", display_name = "Prod", access_name = "prod", parent_key = "workloads" }
    uat           = { name = "mg-example-uat", display_name = "UAT", access_name = "uat", parent_key = "workloads" }
  }

}
run "complete_example_counts" {
  command = apply
  assert {
    condition     = length(output.management_group_ids.branches) == 2 && length(output.management_group_ids.leaves) == 8
    error_message = "The example must include both branches and all eight leaves."
  }
  assert {
    condition     = length(output.access_groups.intermediate_root) + sum([for group in values(output.access_groups.branches) : length(group)]) + sum([for group in values(output.access_groups.leaves) : length(group)]) == 33
    error_message = "The full hierarchy must expose exactly 33 scoped access groups."
  }
}
