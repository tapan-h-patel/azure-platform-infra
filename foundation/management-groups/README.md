# Foundation hierarchy and scoped access

Creates the new-tenant hierarchy and its baseline access together, in state
separate from bootstrap and regional environments. Tenant Root is existing and
unmanaged. No subscription placement, imports, existing-resource deletion, users,
service principals, or group membership changes are performed.

```text
Tenant Root (existing)
└── Intermediate Root
    ├── Platform
    │   ├── Connectivity
    │   ├── Identity
    │   ├── Management
    │   ├── Observability
    │   └── Security
    └── Workloads
        ├── Dev
        ├── Prod
        └── UAT
```

The example creates 11 management groups, 33 Entra security groups, and 33 role
assignments: 77 resources. Each new scope gets Reader, Contributor, and Owner.
No access groups are created at Tenant Root. Defaults are standing assignments;
PIM, approval, and emergency access controls are not implemented.

## Composition and inputs

management-group-with-access composes the base management-group module with
scope-access. The root calls it at three levels: intermediate root, branches,
and leaves. Leaves select their parent through a branch map key. Group names
and access naming tokens must be unique across the hierarchy. All IDs and names
are configurable. The example uses customer placeholders such as mg-example-platform;
it deliberately does not reproduce historical portal IDs like TOP_MG.

Inputs: tenant_id, subscription_id (provider authentication only), parent_management_group_id,
group_owner_object_ids (user/SP UUIDs), root_management_group (name, display_name,
access_name), branch_management_groups (map of the same objects), and
leaf_management_groups (map adding parent_key). Required roles maps suffixes to
built-in role names through terraform.tfvars; the example supplies reader/Reader,
contributor/Contributor and owner/Owner. The parent scope is also explicit in
terraform.tfvars, normally the full Tenant Root management group resource ID.

Outputs management_group_ids and access_groups expose scope IDs and role-keyed
group object IDs, display names, roles, scopes, and assignment IDs.

## Membership and privileges

Platform groups are grp-platform-mg-reader, grp-platform-mg-contributor, and
grp-platform-mg-owner. Group object IDs are bound to the created Platform scope.
Use customer-specific access_name tokens when multiple hierarchies share a tenant.
Duplicate Entra display names cause failure rather than implicit adoption.

Groups start empty; membership is ignored by Terraform and managed by your
identity process. Terraform owns group owner lists and role bindings. Owners can
change membership, so they are privileged. Being an owner is not membership.
Assignments inherit down the hierarchy; child Reader access cannot restrict
inherited Owner permissions. Owner can administer access as well as resources.
Treat human and automation access separately. See docs/access-model.md.

## Local setup (Ubuntu WSL)

Use Terraform 1.17.2, AzureRM 5.14.0, and AzureAD 3.9.0. Both providers target the
same explicit tenant. AzureAD uses Microsoft Graph with independent permissions.
The operator needs permission to create Entra groups and set owners, create
management groups under Tenant Root, and assign Azure roles at the new scopes.
Contributor alone cannot grant RBAC. Tenant policies may restrict creation.
Include the deployment principal among group owners if its Graph permissions
require group ownership. Do not routinely grant Global Administrator to deploy.
Consult the [provider's group permissions](https://registry.terraform.io/providers/hashicorp/azuread/3.9.0/docs/resources/group).

From the repository root:

```bash
cd foundation/management-groups
cp terraform.tfvars.example terraform.tfvars
# Edit tenant/subscription IDs, owner object IDs, and customer naming.
az account show --query '[id,tenantId,name]' -o tsv
terraform init
terraform fmt -check
terraform validate
terraform test
terraform plan -out=foundation.tfplan
```

Review the plan before applying. Existing conflicting test scopes must first be
removed by their administrator; this code does not delete or import them. Replace
the old Platform-only inputs if copied previously. A live old deployment would
require a separate state migration review. The agent has not deployed this root.
Mocked tests verify wiring, not actual Azure/Graph permissions or propagation.

## Backend and fresh provisioning

The Azure Blob backend is configured directly in backend.tf. No backend.hcl is
required. It targets sttfstateshareduksplt001, container tfstate, and key
azlab/foundation/management-groups.tfstate, using Entra/Azure CLI authentication.
Backend settings are literal deployment configuration: Terraform cannot read
input variables inside a backend block. A customer copy must edit these values
before initialization. Do not place credentials or storage account keys here.

The operator needs Storage Blob Data Contributor on the container or an inherited
scope, and storage firewall connectivity. Azure resource Contributor/Owner alone
does not grant blob data access. The account currently has a default-deny public
endpoint and no private endpoint; private networking remains planned.

For a new deployment with no live resources tracked in local state:

```bash
terraform init
terraform validate
terraform plan -out=foundation.tfplan
# Review the plan before provisioning:
terraform apply foundation.tfplan
```

If this directory was previously initialized with a different backend but has no
live local resources to preserve, use terraform init -reconfigure once, then the
remaining commands above. Do not abandon local state that tracks live resources;
resolve that ownership before fresh provisioning. No migration or provisioning
has been performed by this configuration change. Do not reuse an old saved plan.

No subscription is moved by this root. The user intends to move the lab
subscription to Management separately after creation. Review inherited roles and
policies first, and move subscriptions out before destroying their groups.
Destroy removes owned role assignments and security groups, including operational
membership. Review access dependencies before deletion. Stable map keys are
Terraform addresses; use reviewed moved blocks for deployed-resource refactors.
