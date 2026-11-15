# Azure Firewall

Creates a Standard public IP, firewall policy, VNet Azure Firewall, and optional
network rule collection group. Supports Standard or Premium, not Basic (which needs
an additional management subnet design). Inputs: name, policy_name, public_ip_name,
resource_group_name, location, subnet_id, tags, zones, sku_tier,
threat_intelligence_mode (Alert/Deny), and network_rule_collections.

network_rule_collections maps collection names to priority, action (Allow/Deny),
and rules. Each rule maps protocols, source_addresses, destination_addresses and
destination_ports. Empty collections intentionally leave the policy default-deny.
Only network/IP/service-tag rules are supported in this initial module; no broad
allow, inbound DNAT, FQDN/application rules or TLS inspection is generated.
Outputs: private_ip_address, id and policy_id. Subnet must be AzureFirewallSubnet.
Confirm SKU/zone availability and cost before deployment. The public IP is for
firewall egress; it is not a public workload IP or automatic inbound publication.

No diagnostics export, DNS proxy/resolver integration or centralized policy inheritance
is configured. These require explicit follow-up configuration. Firewall and public
IP have ongoing charges even without application workloads; do not deploy solely
to run mocked tests. Providers/backend are inherited. Terraform >=1.17.2,<2,
AzureRM >=5.14,<6. See [pricing](https://azure.microsoft.com/en-us/pricing/details/azure-firewall/).
