mock_provider "azurerm" {}
variables {
  name                     = "cae-test-runners"
  resource_group_name      = "rg-test-runners"
  location                 = "uksouth"
  infrastructure_subnet_id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-runners/subnets/snet-runners"
}
run "internal_environment" {
  command = plan
  assert {
    condition     = azurerm_container_app_environment.runner_environment.internal_load_balancer_enabled && azurerm_container_app_environment.runner_environment.public_network_access == "Disabled"
    error_message = "Runner environment must have no public ingress."
  }
  assert {
    condition     = azurerm_container_app_environment.runner_environment.infrastructure_subnet_id == var.infrastructure_subnet_id && one(azurerm_container_app_environment.runner_environment.workload_profile).workload_profile_type == "Consumption"
    error_message = "Use the supplied dedicated subnet and workload-profile environment."
  }
}
run "reject_short_subnet_id" {
  command = plan
  variables {
    infrastructure_subnet_id = "snet-runners"
  }
  expect_failures = [var.infrastructure_subnet_id]
}
