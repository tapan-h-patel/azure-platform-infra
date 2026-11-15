output "id" {
  description = "Resource group resource ID."
  value       = azurerm_resource_group.resource_group.id
}
output "name" {
  description = "Resource group name."
  value       = azurerm_resource_group.resource_group.name
}
output "location" {
  description = "Resource group location."
  value       = azurerm_resource_group.resource_group.location
}
output "tags" {
  description = "Resource group tags."
  value       = azurerm_resource_group.resource_group.tags
}
