output "groups" {
  description = "Created groups and bindings keyed by role suffix."
  value = { for key, group in azuread_group.security_group : key => {
    object_id          = group.object_id
    display_name       = group.display_name
    role_name          = var.roles[key]
    scope              = var.scope
    role_assignment_id = azurerm_role_assignment.scope_role_assignment[key].id
  } }
}
