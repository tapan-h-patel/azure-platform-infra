output "id" {
  description = "Management group resource ID, suitable as another group's parent or an RBAC/policy scope."
  value       = azurerm_management_group.management_group.id
}

output "name" {
  description = "Stable management group name."
  value       = azurerm_management_group.management_group.name
}

output "display_name" {
  description = "Management group display name."
  value       = azurerm_management_group.management_group.display_name
}

output "parent_management_group_id" {
  description = "Parent management group resource ID."
  value       = azurerm_management_group.management_group.parent_management_group_id
}

output "subscription_association_ids" {
  description = "Association resource IDs keyed by subscription UUID."
  value = {
    for subscription_id, association in azurerm_management_group_subscription_association.subscription_association :
    subscription_id => association.id
  }
}
