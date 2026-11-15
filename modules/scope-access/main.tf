resource "azuread_group" "security_group" {
  for_each                = var.roles
  display_name            = "grp-${var.scope_name}-${var.scope_type}-${each.key}"
  description             = "${each.value} access at ${var.scope}. Membership is managed outside Terraform."
  security_enabled        = true
  mail_enabled            = false
  owners                  = var.group_owner_object_ids
  prevent_duplicate_names = true

  lifecycle {
    ignore_changes = [members]
  }
}
resource "azurerm_role_assignment" "scope_role_assignment" {
  for_each             = var.roles
  scope                = var.scope
  role_definition_name = each.value
  principal_id         = azuread_group.security_group[each.key].object_id
  principal_type       = "Group"
}
