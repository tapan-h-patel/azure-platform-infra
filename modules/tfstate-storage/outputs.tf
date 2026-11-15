output "resource_group_name" {
  description = "State resource group name."
  value       = module.resource_group.name
}

output "storage_account_name" {
  description = "State storage account name."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Private container used by remote backends."
  value       = azurerm_storage_container.tfstate.name
}

output "backend_configuration" {
  description = "Non-secret backend settings. Add a different key for every root/environment."
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
    tenant_id            = var.tenant_id
    subscription_id      = var.subscription_id
    use_azuread_auth     = true
    use_cli              = true
  }
}

