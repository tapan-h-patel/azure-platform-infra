output "virtual_network_id" {
  description = "Runner VNet resource ID."
  value       = azurerm_virtual_network.runner_network.id
}
output "container_apps_subnet_id" {
  description = "Delegated subnet for the runner Container Apps environment."
  value       = azurerm_subnet.container_apps.id
}
output "private_endpoints_subnet_id" {
  description = "Dedicated private endpoint subnet ID."
  value       = azurerm_subnet.private_endpoints.id
}
output "state_private_endpoint_id" {
  description = "State blob private endpoint ID."
  value       = azurerm_private_endpoint.state_storage.id
}
