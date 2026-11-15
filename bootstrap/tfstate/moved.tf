moved {
  from = azurerm_resource_group.tfstate
  to   = module.tfstate_storage.module.resource_group.azurerm_resource_group.resource_group
}
moved {
  from = azurerm_storage_account.tfstate
  to   = module.tfstate_storage.azurerm_storage_account.tfstate
}
moved {
  from = azurerm_storage_container.tfstate
  to   = module.tfstate_storage.azurerm_storage_container.tfstate
}
moved {
  from = azurerm_role_assignment.tfstate_access
  to   = module.tfstate_storage.azurerm_role_assignment.tfstate_access
}
