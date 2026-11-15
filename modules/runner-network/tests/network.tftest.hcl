mock_provider "azurerm" {}
variables {
  resource_group_name           = "rg-test-network"
  location                      = "uksouth"
  name                          = "test-lab-uks-001"
  address_space                 = "10.80.0.0/16"
  container_apps_subnet_cidr    = "10.80.0.0/24"
  private_endpoints_subnet_cidr = "10.80.1.0/24"
  state_storage_account_id      = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-state/providers/Microsoft.Storage/storageAccounts/teststate"
}
run "private_state_network" {
  command = plan
  assert {
    condition     = azurerm_subnet.container_apps.delegation[0].service_delegation[0].name == "Microsoft.App/environments" && length(azurerm_subnet.private_endpoints.delegation) == 0
    error_message = "Only the dedicated runner subnet should be delegated to Container Apps."
  }
  assert {
    condition     = azurerm_private_endpoint.state_storage.private_service_connection[0].private_connection_resource_id == var.state_storage_account_id && azurerm_private_endpoint.state_storage.private_service_connection[0].subresource_names == tolist(["blob"])
    error_message = "The endpoint must target only the caller's state storage blob service."
  }
  assert {
    condition     = azurerm_private_dns_zone.blob_storage.name == "privatelink.blob.core.windows.net" && !azurerm_private_dns_zone_virtual_network_link.runner_network.registration_enabled
    error_message = "Use the blob private DNS zone without VM auto-registration."
  }
}
run "reject_undersized_runner_subnet" {
  command = plan
  variables {
    container_apps_subnet_cidr = "10.80.0.0/28"
  }
  expect_failures = [var.container_apps_subnet_cidr]
}
