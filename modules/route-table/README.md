# Firewall transit route table

Creates a route table, separate user-defined routes, and subnet associations.
Inputs: name, resource_group_name, location, tags, bgp_route_propagation_enabled,
next_hop_ip_address, routes (route-name to destination IPv4 prefix), and subnet_ids
(logical key to existing subnet ID). Every route uses VirtualAppliance and the
supplied next-hop IP. Outputs: id, routes, associated_subnet_ids.

Use a reachable forwarding firewall/NVA address, not just a hub subnet address.
Do not associate multiple route tables with one subnet, mix inline route management
with these route resources, or attach workload routes to AzureFirewallSubnet.
UDRs do not create forwarding capability or allow firewall/NSG traffic themselves.
The composition supplies symmetric workload/return routes and disables BGP propagation.
Providers/backend are inherited. Terraform >=1.17.2,<2 and AzureRM >=5.14,<6.
