# Hub-and-spoke connectivity deployment

Status: undeployed reference awaiting user review. The target
[vending design](../../../docs/subscription-vending-design.md) uses central
AVNM/IPAM and staged cross-subscription spokes; this static-CIDR, single-provider
example does not implement that service. No Terraform configuration was changed
while documenting the target design.

Module-only root. Calls modules/hub-spoke with values from terraform.tfvars.
The example creates one hub and Management/Identity spokes within one subscription,
each in its own resource group. Add spoke entries to create additional networks.
This is new network infrastructure, not a change to the paused runner topology.

```text
Management spoke <--> Hub + Azure Firewall <--> Identity spoke
                          |
                       Internet
```

There is no direct spoke-to-spoke peering. Peerings, subnet route tables and hub
return routes direct routed workload traffic through Azure Firewall. The example
includes default and RFC1918 summary routes plus generated VNet/subnet routes.
AzureFirewallSubnet is excluded from workload route tables.

## Configure and review

Use Terraform 1.17.2 / AzureRM 5.14.0. Copy terraform.tfvars.example to ignored
terraform.tfvars for a customer deployment and set tenant/subscription, location,
hub, spokes, firewall and transit_routes. Every module argument is a variable;
there are no resource blocks in the root. Provider registration is disabled;
confirm Microsoft.Network registration and networking/RBAC permissions beforehand.

The local lab tfvars uses the existing lab subscription, with proposed ranges:
hub 10.100.0.0/16, Management 10.110.0.0/16, Identity 10.120.0.0/16. This does not
claim that the pending Connectivity subscription exists. Review overlaps with
existing Azure/on-prem/VPN/runner ranges and required zone/SKU availability before
planning. Change subscription_id explicitly when the target subscription is ready.

From the repository root in WSL:

```bash
cd platform/connectivity/hub-spoke
terraform init
terraform validate
terraform test
terraform plan -out=hub-spoke.tfplan
```

Review before applying. Azure Firewall/public IP/peering traffic can incur charges;
no real Azure plan or deployment has been run by the agent. Standalone mocked
VNet/topology tests are also available in modules/vnet and modules/hub-spoke.

backend.tf configures the lab state account directly with its separate key
azlab/platform/connectivity/hub-spoke.tfstate. Update literal backend settings for
each customer before initializing; Terraform cannot use tfvars in backend blocks.
Do not share another deployment root's key or abandon existing state.

## Firewall policy

The example deliberately has network_rule_collections = {}. Routes alone do not
allow traffic; the initial firewall denies it. Explicitly add only required flows.
For example, allow HTTPS from the Management subnet to an Identity service:

```hcl
network_rule_collections = {
  management_to_identity = {
    priority = 200
    action   = "Allow"
    rules = {
      https = {
        protocols             = ["TCP"]
        source_addresses      = ["10.110.1.0/24"]
        destination_addresses = ["10.120.1.0/24"]
        destination_ports     = ["443"]
      }
    }
  }
}
```

Place this inside the firewall object in terraform.tfvars. Destination listeners,
NSGs and application permissions still apply. No default allow-all or inbound DNAT
is created. Internet egress requires its own reviewed allow rules; FQDN/application
rules and private DNS/proxy integration are not implemented yet.

## Limits and verification after an approved deployment

The first composition targets one subscription; lower modules can be used with
explicit provider aliases in later cross-subscription roots. No gateway transit,
NSGs, VPN, private endpoints, workload VMs or durable firewall diagnostics are
created. Same-subnet and Azure platform traffic are not a promise of inspection.
Managed-service subnets need service-specific routing validation before adoption.

After deployment, verify peerings are Connected, spoke NIC effective routes show
the firewall next hop for default/other-spoke/hub-service prefixes, hub return routes
are symmetric, and permitted/denied tests match the firewall policy. Use appropriate
Network Watcher tests and firewall diagnostic logs once logging is configured.
Mocked tests cannot validate those data-plane behaviors. Do not connect production
workloads until routing, policy, logging and recovery access have been tested.

References:
- [Azure hub-spoke architecture](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke)
- [Azure route selection](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Azure Firewall pricing](https://azure.microsoft.com/en-us/pricing/details/azure-firewall/)
