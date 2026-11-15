output "management_group_ids" {
  description = "Intermediate root, branch, and leaf scope IDs."
  value = {
    intermediate_root = module.intermediate_root.id
    branches          = { for key, group in module.branches : key => group.id }
    leaves            = { for key, group in module.leaves : key => group.id }
  }
}
output "access_groups" {
  description = "Security group object IDs, display names, roles, and scopes."
  value = {
    intermediate_root = module.intermediate_root.groups
    branches          = { for key, group in module.branches : key => group.groups }
    leaves            = { for key, group in module.leaves : key => group.groups }
  }
}
