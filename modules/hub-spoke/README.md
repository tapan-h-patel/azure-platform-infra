# Hub-and-spoke topology

Composes resource-group, vnet, vnet-peering, azure-firewall and route-table modules.
Creates one hub, an arbitrary map of spokes, and two directional peerings per spoke.
There are no spoke-to-spoke peerings. Both directions allow forwarded traffic;
gateway transit/remote gateways are disabled because no gateway is provisioned.

Required inputs: location, hub, spokes, firewall and transit_routes. All resource
names, CIDRs, DNS values, tags and firewall allow rules come from the caller.
hub/spoke network objects contain resource_group_name, virtual_network_name,
address_space, dns_servers, route_table_name, tags and subnets. Spokes additionally
supply hub_to_spoke_peering_name and spoke_to_hub_peering_name. Subnets include the
vnet module fields plus route_via_hub. Ordinary workload subnets must set it true;
reserved gateway/firewall infrastructure subnets must set it false.

firewall supplies name, policy_name, public_ip_name, subnet_key, sku_tier, zones,
threat_intelligence_mode and network_rule_collections. Its subnet key must select
AzureFirewallSubnet with a single /26-or-larger IPv4 range. transit_routes is an
explicit route-name/prefix map including 0.0.0.0/0; private summaries are recommended
for external private destinations. Address spaces across hub/spokes must not overlap.
The composition creates a distinct resource group for every network.

## Routing behavior

Every ordinary subnet receives a table whose VirtualAppliance next hop is the
firewall's computed private IP. Tables include caller transit prefixes, every spoke
VNet prefix, and ordinary hub/spoke subnet prefixes. More-specific managed subnet
routes avoid relying only on a default route, which cannot override a more-specific
VNet/system route. Hub workload tables provide the return path through the firewall.
AzureFirewallSubnet receives no workload table; the firewall uses connected/peered
routes toward the destination. BGP propagation is disabled on workload tables.

This forces the configured routed workload flows toward the hub. It does not mean
every packet in Azure is inspectable: same-subnet/link-local/platform DNS traffic,
private endpoint host routes, service-specific routing and future more-specific
UDRs need separate review. Existing VNets/peerings and unmanaged routes are not
adopted. This module does not implement VPN/ExpressRoute, Virtual WAN, NSGs, DNS
forwarders, or private endpoints. Managed service subnet requirements need a separate
design before reusing this composition for AKS/Container Apps/gateways.

## Scope and outputs

One inherited AzureRM provider deploys this composition into one subscription.
Cross-subscription topology requires explicit provider-alias composition using the
lower-level modules; do not assume passing subscription IDs dynamically selects
providers. Multiple calls can create regional hubs with nonoverlapping address plans.

Outputs: hub_vnet_id, spoke_vnet_ids, subnet_ids, firewall_private_ip, firewall_id,
firewall_policy_id, route_table_ids, peerings, routed_subnets and routes. All map
keys are Terraform addresses; use reviewed moved blocks when renaming deployed keys.
Providers/backend are supplied by the root. Compatible Terraform >=1.17.2,<2 and
AzureRM >=5.14,<6. No infrastructure was deployed by the agent.

See ../../platform/connectivity/hub-spoke/README.md for the root example.
Mocked tests verify routing/peering composition and reject overlapping VNets or
an invalid firewall subnet. They do not prove effective routes or connectivity.
