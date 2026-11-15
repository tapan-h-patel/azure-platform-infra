output "id" {
  description = "Environment ID for the future ephemeral runner job."
  value       = azurerm_container_app_environment.runner_environment.id
}
