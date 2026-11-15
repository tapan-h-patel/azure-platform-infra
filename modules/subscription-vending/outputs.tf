output "subscription_id" {
  description = "Created subscription UUID, suitable for downstream provider configuration."
  value       = azurerm_subscription.subscription.subscription_id
}
output "subscription_resource_id" {
  description = "Full /subscriptions/<uuid> resource ID; this is not the billing alias resource ID."
  value       = "/subscriptions/${azurerm_subscription.subscription.subscription_id}"
}
output "alias_resource_id" {
  description = "Alias API resource ID managed by Terraform."
  value       = azurerm_subscription.subscription.id
}
output "subscription_name" {
  description = "Subscription display name."
  value       = azurerm_subscription.subscription.subscription_name
}
output "management_group_id" {
  description = "Target management group scope."
  value       = azurerm_management_group_subscription_association.subscription_association.management_group_id
}
output "tenant_id" {
  description = "Tenant returned by subscription creation."
  value       = azurerm_subscription.subscription.tenant_id
}
