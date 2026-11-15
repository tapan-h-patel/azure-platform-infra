# Runner environment

Creates an internal, VNet-integrated Container Apps workload-profile environment
with the Consumption profile and public network access disabled. The input subnet
must be dedicated, delegated to Microsoft.App/environments, /27 or larger, and in
the deployment's subscription/region. Location/subscription consistency is an
operator prerequisite, not verified by this module.

Inputs: name, existing resource_group_name, location, infrastructure_subnet_id,
optional tags. Output id is for future runner jobs. AzureRM >=5.14,<6 is declared;
the deployment caller pins exact versions and supplies providers/backend.

This module creates no job, runner image, GitHub credentials, automation identity,
RBAC, scaler or workflow. It has no public application ingress. Outbound service
connectivity is still required. Durable monitoring/diagnostic export is pending;
no Log Analytics workspace or public ingestion endpoint is created here.
Environment-managed Azure infrastructure can incur charges even without a runner
job; review the environment plan and current service pricing before deployment.

Mocked tests check internal ingress, the selected profile/subnet, and invalid
subnet IDs; no deployment or connection tests have been run. See
../../docs/ci-cd-design.md for staged implementation and public repository policy.
