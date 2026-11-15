output "hub_vnet_id" { value = module.vnets["hub"].id }
output "spoke_vnet_ids" { value = { for key in keys(var.spokes) : key => module.vnets[key].id } }
output "subnet_ids" { value = { for key, network in module.vnets : key => network.subnet_ids } }
output "firewall_private_ip" { value = module.firewall.private_ip_address }
output "firewall_id" { value = module.firewall.id }
output "firewall_policy_id" { value = module.firewall.policy_id }
output "route_table_ids" { value = { for key, table in module.transit_routes : key => table.id } }

output "peerings" {
  value = {
    hub_to_spoke = { for key, peering in module.hub_to_spoke : key => peering.configuration }
    spoke_to_hub = { for key, peering in module.spoke_to_hub : key => peering.configuration }
  }
}
output "routed_subnets" { value = { for key, table in module.transit_routes : key => table.associated_subnet_ids } }
output "routes" { value = { for key, table in module.transit_routes : key => table.routes } }
