mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    override_during = plan
    defaults        = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test" }
  }
  mock_resource "azurerm_virtual_network" {
    override_during = plan
    defaults        = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test" }
  }
  mock_resource "azurerm_public_ip" {
    override_during = plan
    defaults        = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-test" }
  }
  mock_resource "azurerm_firewall_policy" {
    override_during = plan
    defaults        = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/firewallPolicies/policy-test" }
  }
  mock_resource "azurerm_route_table" {
    override_during = plan
    defaults        = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/routeTables/rt-test" }
  }
}
override_resource {
  target          = module.vnets["hub"].azurerm_subnet.subnet["firewall"]
  override_during = plan
  values = {
    id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/AzureFirewallSubnet"
  }
}
override_resource {
  target          = module.firewall.azurerm_firewall.firewall
  override_during = plan
  values = {
    ip_configuration = { private_ip_address = "10.100.0.4" }
  }
}

override_resource {
  target          = module.vnets["hub"].azurerm_virtual_network.virtual_network
  override_during = plan
  values          = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-hub" }
}

override_resource {
  target          = module.vnets["management"].azurerm_virtual_network.virtual_network
  override_during = plan
  values          = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-management" }
}

override_resource {
  target          = module.vnets["identity"].azurerm_virtual_network.virtual_network
  override_during = plan
  values          = { id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-identity" }
}

variables {
  location = "uksouth"
  transit_routes = {
    default     = "0.0.0.0/0"
    private-10  = "10.0.0.0/8"
    private-172 = "172.16.0.0/12"
    private-192 = "192.168.0.0/16"
  }
  hub = {
    resource_group_name  = "rg-example-hub-uks-001"
    virtual_network_name = "vnet-example-hub-uks-001"
    address_space        = ["10.100.0.0/16"]
    dns_servers          = []
    route_table_name     = "rt-example-hub-uks-001"
    tags                 = { workload = "connectivity", environment = "lab", managed_by = "terraform", repository = "azure-platform-infra" }
    subnets = {
      firewall = {
        name                              = "AzureFirewallSubnet"
        address_prefixes                  = ["10.100.0.0/26"]
        default_outbound_access_enabled   = false
        private_endpoint_network_policies = "Enabled"
        route_via_hub                     = false
      }
      services = {
        name                              = "snet-example-hub-services-uks-001"
        address_prefixes                  = ["10.100.1.0/24"]
        default_outbound_access_enabled   = false
        private_endpoint_network_policies = "Enabled"
        route_via_hub                     = true
      }
    }
  }
  spokes = {
    management = {
      resource_group_name       = "rg-example-management-uks-001"
      virtual_network_name      = "vnet-example-management-uks-001"
      address_space             = ["10.110.0.0/16"]
      dns_servers               = []
      route_table_name          = "rt-example-management-uks-001"
      hub_to_spoke_peering_name = "peer-hub-to-management"
      spoke_to_hub_peering_name = "peer-management-to-hub"
      tags                      = { workload = "management", environment = "lab", managed_by = "terraform", repository = "azure-platform-infra" }
      subnets = {
        workloads = {
          name                              = "snet-example-management-workloads-uks-001"
          address_prefixes                  = ["10.110.1.0/24"]
          default_outbound_access_enabled   = false
          private_endpoint_network_policies = "Enabled"
          route_via_hub                     = true
        }
      }
    }
    identity = {
      resource_group_name       = "rg-example-identity-uks-001"
      virtual_network_name      = "vnet-example-identity-uks-001"
      address_space             = ["10.120.0.0/16"]
      dns_servers               = []
      route_table_name          = "rt-example-identity-uks-001"
      hub_to_spoke_peering_name = "peer-hub-to-identity"
      spoke_to_hub_peering_name = "peer-identity-to-hub"
      tags                      = { workload = "identity", environment = "lab", managed_by = "terraform", repository = "azure-platform-infra" }
      subnets = {
        workloads = {
          name                              = "snet-example-identity-workloads-uks-001"
          address_prefixes                  = ["10.120.1.0/24"]
          default_outbound_access_enabled   = false
          private_endpoint_network_policies = "Enabled"
          route_via_hub                     = true
        }
      }
    }
  }
  firewall = {
    name                     = "afw-example-hub-uks-001"
    policy_name              = "afwp-example-hub-uks-001"
    public_ip_name           = "pip-example-firewall-uks-001"
    subnet_key               = "firewall"
    sku_tier                 = "Standard"
    zones                    = []
    threat_intelligence_mode = "Deny"
    # Empty is intentional: policy denies traffic until explicit rules are supplied.
    network_rule_collections = {}
  }

}
run "hub_spoke_forwarding_and_routes" {
  assert {
    condition     = alltrue([for key, peering in output.peerings.hub_to_spoke : peering.remote_vnet_id == output.spoke_vnet_ids[key]]) && alltrue([for peering in values(output.peerings.spoke_to_hub) : peering.remote_vnet_id == output.hub_vnet_id])
    error_message = "Both peering directions must target their intended remote VNet."
  }

  command = plan
  assert {
    condition     = length(output.peerings.hub_to_spoke) == 2 && length(output.peerings.spoke_to_hub) == 2 && alltrue([for peering in values(output.peerings.spoke_to_hub) : peering.forwarded_traffic && !peering.gateway_transit && !peering.remote_gateway])
    error_message = "Create two directional peerings per spoke with forwarding and no gateway assumptions."
  }
  assert {
    condition     = alltrue(flatten([for routes in values(output.routes) : [for route in values(routes) : route.next_hop_ip == "10.100.0.4" && route.next_hop_type == "VirtualAppliance"]])) && output.routes["identity"]["spoke-management-0"].prefix == "10.110.0.0/16" && output.routes["management"]["subnet-hub-services-0"].prefix == "10.100.1.0/24"
    error_message = "Route defaults, private prefixes, other spokes and hub workload destinations through the firewall."
  }
  assert {
    condition     = keys(output.routed_subnets["hub"]) == ["services"] && keys(output.routed_subnets["identity"]) == ["workloads"]
    error_message = "Attach transit tables to workloads but never to AzureFirewallSubnet."
  }
}

run "reject_overlapping_vnets" {
  command = plan
  variables {
    spokes = {
      overlap = {
        resource_group_name       = "rg-overlap"
        virtual_network_name      = "vnet-overlap"
        address_space             = ["10.100.0.0/16"]
        dns_servers               = []
        route_table_name          = "rt-overlap"
        tags                      = {}
        hub_to_spoke_peering_name = "hub-overlap"
        spoke_to_hub_peering_name = "overlap-hub"
        subnets = {
          workloads = { name = "snet-overlap", address_prefixes = ["10.100.2.0/24"], default_outbound_access_enabled = false, private_endpoint_network_policies = "Enabled", route_via_hub = true }
        }
      }
    }
  }
  expect_failures = [terraform_data.topology_validation]
}
run "reject_wrong_firewall_subnet" {
  command = plan
  variables {
    firewall = {
      name                     = "afw-test"
      policy_name              = "afwp-test"
      public_ip_name           = "pip-test"
      subnet_key               = "services"
      sku_tier                 = "Standard"
      zones                    = []
      threat_intelligence_mode = "Deny"
      network_rule_collections = {}
    }
  }
  expect_failures = [var.firewall]
}
