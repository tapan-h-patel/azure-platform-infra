# GitHub runner platform: environment stage

Creates the runner resource group and internal Container Apps environment using
modules/runner-environment. No running/registered runner exists yet. GitHub jobs,
images, autoscaling, authentication and workflows are the next implementation stage.
The root calls modules/resource-group for its resource group. moved.tf preserves
the former direct resource address for existing state; review the next plan.

Deploy runner-network first, then copy terraform.tfvars.example to ignored
terraform.tfvars. Supply its exact container_apps_subnet_id as
infrastructure_subnet_id, with matching subscription and location. Confirm
Microsoft.App is registered and deployment permissions cover the environment,
resource groups, managed infrastructure and subnet integration.
Resource group and Container Apps names are explicit resource_group_name and
environment_name inputs. Supply the complete tags map in terraform.tfvars; the
root does not add hidden naming prefixes or baseline tag values.

From this directory: terraform init, terraform validate, and
terraform plan -out=runner-environment.tfplan. Review the plan and pricing before
any apply. Copy output runner_environment_id to future job configuration.
No automatic provider registration or deployment occurs.

Terraform 1.17.2 and AzureRM 5.14.0 are pinned. The root lock file is retained.
Local state is for isolated bootstrap review only. Before shared use configure
an Azure backend directly in backend.tf with its own key, such as
<customer>/platform/management/github-runners.tfstate, using Entra authentication.
Protect existing state during any backend change; do not share other roots' keys.

Workload-profile networking supports access to the state blob private endpoint
through the linked DNS zone. The environment has no public ingress. It still needs
outbound GitHub, registry, Entra, Azure API and provider access. There is no egress
allowlist, custom firewall or durable monitoring integration in this first stage.
These must be designed before customer production use. Container Apps does not
support Docker-in-Docker; future Terraform jobs will use non-container actions.

Do not register a runner accepting arbitrary PR code from the current public
repository. Choose the trusted workflow policy described in
../../../docs/ci-cd-design.md first. No credentials or deployment permissions are
attached to this environment. Actual runner identity and registration are pending.
