# Virtual network

Creates one VNet and separately managed subnets. Inputs: name, resource_group_name,
location, tags, dns_servers, address_space (IPv4 CIDR list), and subnets keyed by
stable logical names. Each subnet supplies name, address_prefixes,
default_outbound_access_enabled and private_endpoint_network_policies.
Outputs: id, name and subnet_ids keyed by logical subnet name.

Checks IPv4 syntax, subnet containment and subnet overlap. DNS servers are explicit;
an empty list uses Azure DNS. No implicit default outbound is selected by the module:
the caller supplies the flag. VNet names/address ranges are customer inputs. Do not
also manage the same subnets inline in a VNet resource or another state.

This module does not create resource groups, NSGs, delegation, private endpoints,
peering or routes. Compose those separately. Delegated managed-service subnets may
need a more specialized module such as runner-network. Removing a subnet can affect
its dependent services; inspect replacement/destruction plans before applying.
Providers/backend are inherited. Terraform >=1.17.2,<2 and AzureRM >=5.14,<6.
Tests mock Azure and check default outbound settings, containment and overlap.
