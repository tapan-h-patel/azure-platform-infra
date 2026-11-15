output "id" {
  description = "Management group resource ID."
  value       = module.management_group.id
}
output "parent_management_group_id" {
  description = "Parent management group ID."
  value       = module.management_group.parent_management_group_id
}
output "groups" {
  description = "Scoped access groups and role bindings."
  value       = module.scope_access.groups
}
