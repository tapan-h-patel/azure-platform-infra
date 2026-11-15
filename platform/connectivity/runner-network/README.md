# Runner connectivity deployment

First stage of private self-hosted runner infrastructure. Owns a network resource
group and calls modules/runner-network. Separate from the runner environment root
and foundation hierarchy/state. No Azure deployment has been run by the agent.
The resource group is created through modules/resource-group. moved.tf preserves
the former direct resource address for any existing state; review a fresh plan.

1. Copy terraform.tfvars.example to ignored terraform.tfvars.
2. Replace tenant, target subscription, name, existing storage resource ID and tags.
   Supply resource_group_name explicitly and the full tags map (including managed_by
   and repository). Naming inputs belong in terraform.tfvars, not root module calls.
   Review example CIDRs for containment, overlap and reserved network ranges.
3. Confirm Microsoft.Network is registered and permissions include networking,
   private DNS management, and approval of the storage private endpoint connection.
4. From this directory run terraform init, terraform validate, and
   terraform plan -out=runner-network.tfplan. Review before applying.
5. Supply output container_apps_subnet_id to the management runner environment root.

Terraform 1.17.2 / AzureRM 5.14.0 are pinned and the root lock file is retained.
The commented backend.tf means local state for isolated bootstrap review; before
shared use configure an Azure backend directly in backend.tf, using a distinct key
such as <customer>/platform/connectivity/runner-network.tfstate and Entra auth.
Never use the foundation state key. Protect local state/plans and review any
migration if resources already exist. Do not abandon live state.

The account's public endpoint is deliberately unchanged. Do not disable it until
private DNS, runner access and operator/VPN recovery access have been tested.
From a VNet-connected client the normal <account>.blob.core.windows.net hostname
should resolve to the private IP; then test authenticated state/blob access. WSL
on a laptop cannot reach the private IP without appropriate VPN/routing/DNS.

No jobs or workflows are created. Read ../../../docs/ci-cd-design.md before enabling
private runner jobs, especially because the current GitHub repository is public.
