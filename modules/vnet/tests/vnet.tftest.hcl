mock_provider "azurerm" {}
variables {
  name                = "vnet-test"
  resource_group_name = "rg-test"
  location            = "uksouth"
  address_space       = ["10.1.0.0/16"]
  dns_servers         = []
  tags                = {}
  subnets = {
    workloads = { name = "snet-workloads", address_prefixes = ["10.1.1.0/24"], default_outbound_access_enabled = false, private_endpoint_network_policies = "Enabled" }
  }
}
run "no_implicit_outbound" {
  command = plan
  assert {
    condition     = !azurerm_subnet.subnet["workloads"].default_outbound_access_enabled
    error_message = "Preserve explicit disabled default outbound access."
  }
}
run "reject_subnet_outside_vnet" {
  command = plan
  variables {
    subnets = { outside = { name = "snet-outside", address_prefixes = ["10.2.1.0/24"], default_outbound_access_enabled = false, private_endpoint_network_policies = "Enabled" } }
  }
  expect_failures = [azurerm_virtual_network.virtual_network]
}
run "reject_overlapping_subnets" {
  command = plan
  variables {
    subnets = {
      one = { name = "snet-one", address_prefixes = ["10.1.1.0/24"], default_outbound_access_enabled = false, private_endpoint_network_policies = "Enabled" }
      two = { name = "snet-two", address_prefixes = ["10.1.1.0/25"], default_outbound_access_enabled = false, private_endpoint_network_policies = "Enabled" }
    }
  }
  expect_failures = [azurerm_virtual_network.virtual_network]
}
