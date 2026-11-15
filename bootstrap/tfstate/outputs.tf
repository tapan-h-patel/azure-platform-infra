output "resource_group_name" {
  description = "State resource group name."
  value       = module.tfstate_storage.resource_group_name
}
output "storage_account_name" {
  description = "State storage account name."
  value       = module.tfstate_storage.storage_account_name
}
output "container_name" {
  description = "Private state container name."
  value       = module.tfstate_storage.container_name
}
output "backend_configuration" {
  description = "Non-secret backend settings; supply a unique key per deployment root."
  value       = module.tfstate_storage.backend_configuration
}
