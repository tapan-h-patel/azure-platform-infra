# Runner network

Creates a new dedicated VNet, a Microsoft.App/environments-delegated runner subnet,
a separate private endpoint subnet, a blob private DNS zone/link and an endpoint
to an existing state storage account. Does not modify storage public access, grant
blob roles, create peering/VPN, or register a GitHub runner.

Inputs: existing resource_group_name, location, naming stem name, address_space,
container_apps_subnet_cidr (/27 or larger), private_endpoints_subnet_cidr,
state_storage_account_id, and optional tags. Check CIDR containment, subnet overlap,
existing connected networks and ACA reserved address ranges before deployment;
input validation checks syntax/size, not full network compatibility. The delegated
subnet is exclusively for ACA. The nondelegated subnet owns private endpoints.

Outputs: virtual_network_id, container_apps_subnet_id, private_endpoints_subnet_id,
state_private_endpoint_id. The caller supplies authentication/backend/version pins.
AzureRM compatible bound is >=5.14,<6; roots pin 5.14.0.

The DNS zone is created here for a new isolated VNet. A customer with centrally
owned DNS should adapt ownership before deploying; do not manage an existing zone
from two roots. Uses Azure-provided DNS; custom DNS needs forwarding configuration.
Private link approval requires target storage permissions. Creating this endpoint
does not disable the public endpoint or grant data access. No NSG/custom egress
filtering, NAT Gateway, hub peering, VPN or private DNS resolver is provisioned.

Tests mock Azure and check subnet separation/delegation, blob service targeting,
DNS settings and subnet size rejection. They do not prove connectivity. Configure
registry credentials and target access separately, and don't expose private
runners to untrusted PRs. See ../../docs/ci-cd-design.md.
