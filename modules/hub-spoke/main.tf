locals {
  networks = merge({ hub = var.hub }, var.spokes)
  address_ranges = flatten([for key, network in local.networks : [for prefix in network.address_space : {
    key   = key
    first = try(sum([for i, octet in split(".", cidrhost(prefix, 0)) : tonumber(octet) * pow(256, 3 - i)]), -1)
    last  = try(sum([for i, octet in split(".", cidrhost(prefix, -1)) : tonumber(octet) * pow(256, 3 - i)]), -1)
  }]])
  spoke_routes           = merge({}, [for key, spoke in var.spokes : { for index, prefix in spoke.address_space : "spoke-${key}-${index}" => prefix }]...)
  workload_subnet_routes = merge({}, flatten([for key, network in local.networks : [for subnet_key, subnet in network.subnets : { for index, prefix in subnet.address_prefixes : "subnet-${key}-${subnet_key}-${index}" => prefix } if subnet.route_via_hub]])...)
  routes                 = merge(var.transit_routes, local.spoke_routes, local.workload_subnet_routes)
}
resource "terraform_data" "topology_validation" {
  input = { hub = var.hub.address_space, spokes = { for key, spoke in var.spokes : key => spoke.address_space } }
  lifecycle {
    precondition {
      condition     = !contains(keys(var.spokes), "hub") && alltrue(flatten([for i, left in local.address_ranges : [for j, right in local.address_ranges : i == j || left.last < right.first || right.last < left.first]]))
      error_message = "Hub/spoke address spaces must not overlap; the spoke key hub is reserved."
    }
    precondition {
      condition     = alltrue(flatten([for key, network in local.networks : [for subnet in values(network.subnets) : contains(["GatewaySubnet", "AzureFirewallSubnet", "AzureFirewallManagementSubnet", "RouteServerSubnet"], subnet.name) ? !subnet.route_via_hub : subnet.route_via_hub]]))
      error_message = "Workload subnets must route through the hub; reserved infrastructure subnets must not receive workload route tables."
    }
    precondition {
      condition     = length(distinct([for network in values(local.networks) : network.resource_group_name])) == length(local.networks)
      error_message = "This composition creates a separate resource group per VNet; resource group names must be distinct."
    }
  }
}
module "resource_groups" {
  source     = "../resource-group"
  for_each   = local.networks
  name       = each.value.resource_group_name
  location   = var.location
  tags       = each.value.tags
  depends_on = [terraform_data.topology_validation]
}
module "vnets" {
  source              = "../vnet"
  for_each            = local.networks
  name                = each.value.virtual_network_name
  resource_group_name = module.resource_groups[each.key].name
  location            = var.location
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  subnets             = each.value.subnets
  tags                = each.value.tags
}
module "firewall" {
  source                   = "../azure-firewall"
  name                     = var.firewall.name
  policy_name              = var.firewall.policy_name
  public_ip_name           = var.firewall.public_ip_name
  resource_group_name      = module.resource_groups["hub"].name
  location                 = var.location
  subnet_id                = module.vnets["hub"].subnet_ids[var.firewall.subnet_key]
  sku_tier                 = var.firewall.sku_tier
  zones                    = var.firewall.zones
  threat_intelligence_mode = var.firewall.threat_intelligence_mode
  network_rule_collections = var.firewall.network_rule_collections
  tags                     = var.hub.tags
}
module "hub_to_spoke" {
  source                       = "../vnet-peering"
  for_each                     = var.spokes
  name                         = each.value.hub_to_spoke_peering_name
  resource_group_name          = module.resource_groups["hub"].name
  virtual_network_name         = module.vnets["hub"].name
  remote_virtual_network_id    = module.vnets[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
module "spoke_to_hub" {
  source                       = "../vnet-peering"
  for_each                     = var.spokes
  name                         = each.value.spoke_to_hub_peering_name
  resource_group_name          = module.resource_groups[each.key].name
  virtual_network_name         = module.vnets[each.key].name
  remote_virtual_network_id    = module.vnets["hub"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
module "transit_routes" {
  source                        = "../route-table"
  for_each                      = local.networks
  name                          = each.value.route_table_name
  resource_group_name           = module.resource_groups[each.key].name
  location                      = var.location
  bgp_route_propagation_enabled = false
  next_hop_ip_address           = module.firewall.private_ip_address
  routes                        = local.routes
  subnet_ids                    = { for key, subnet in each.value.subnets : key => module.vnets[each.key].subnet_ids[key] if subnet.route_via_hub }
  tags                          = each.value.tags
  depends_on                    = [module.hub_to_spoke, module.spoke_to_hub]
}
