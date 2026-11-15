# Directional VNet peering

Creates one direction of a peering; call it twice for a complete hub/spoke pair.
Required inputs: name, resource_group_name, virtual_network_name,
remote_virtual_network_id, allow_virtual_network_access, allow_forwarded_traffic,
allow_gateway_transit, use_remote_gateways. Outputs: id and configuration.

A peering does not provide routing/transitivity or firewall rules. Both sides need
permissions and nonoverlapping address spaces. Gateway options must match actual
gateway deployment; the hub-spoke composition keeps them disabled. Reuse this module
with explicit provider aliases for different subscriptions; Terraform provider
selection cannot be derived dynamically from a map of subscription IDs.
Providers/backend are inherited. Terraform >=1.17.2,<2 and AzureRM >=5.14,<6.
