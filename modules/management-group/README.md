# Management group module

Creates one management group under an explicit parent. Call it repeatedly to
compose a customer foundation hierarchy. Subscription associations are optional
and empty by default. No tenant IDs, credentials, backend, provider configuration,
policy assignments, or role assignments are embedded in this module.

## Foundational platform example

In a deployment root, configure the AzureRM provider and pin its version to
5.14.0 and Terraform to 1.17.2, as in this repository's environment root. Supply
customer-specific values as root variables. The deployable caller lives in
[`foundation/management-groups`](../../foundation/management-groups/README.md),
separate from regional environments. From that root, a minimal composition is:

```hcl
module "platform_management_group" {
  source = "../../modules/management-group"

  name                       = "mg-${var.customer_code}-platform"
  display_name               = "${var.customer_name} Platform"
  parent_management_group_id = var.foundation_parent_management_group_id
}

module "connectivity_management_group" {
  source = "../../modules/management-group"

  name                       = "mg-${var.customer_code}-connectivity"
  display_name               = "${var.customer_name} Connectivity"
  parent_management_group_id = module.platform_management_group.id
  subscription_ids           = var.connectivity_subscription_ids
}
```

This abbreviated example illustrates the base module interface. The actual foundation
root now uses the composed management-group-with-access module at intermediate,
branch, and leaf levels, including scoped security groups and role bindings. Declare
the referenced variables if using this snippet independently. Keep subscription IDs empty until a
subscription move has been reviewed. For a top-level group, supply the existing
tenant-root resource ID explicitly:
`/providers/Microsoft.Management/managementGroups/<tenant-id>`.
For an existing non-root parent, use its full resource ID instead.

## Inputs

| Input | Type | Default | Purpose |
|---|---|---|---|
| `name` | string | Required | Stable tenant-unique ID, 1-90 lowercase letters/digits/hyphens |
| `display_name` | string | null | Friendly name; defaults to the stable name |
| `parent_management_group_id` | string | Required | Full existing parent resource ID, or another module's `id` |
| `subscription_ids` | set(string) | `[]` | Subscription UUIDs explicitly owned by this module's associations |

Outputs: `id`, `name`, `display_name`, `parent_management_group_id`, and
`subscription_association_ids` (map keyed by subscription UUID).

## Access, lifecycle, and ownership

- Authenticate the provider to the intended customer tenant. Management groups
  are tenant-scoped and have no Azure location or tags.
- Confirm permissions on the parent and any subscriptions being moved. A
  subscription role alone does not necessarily grant access to its parent group.
  Tenant settings can restrict management group creation. Provider registration
  and tenant onboarding are deployment-root responsibilities.
- Moving a subscription changes inherited RBAC and policy. Review source and
  destination scopes and access before opting into associations.
- Each group and subscription association must have one Terraform owner. Never
  manage the same subscription through two module calls or another root. Do not
  combine these association resources with inline `subscription_ids` management
  on the same Azure management group elsewhere.
- Removing a managed association can move its subscription back to the tenant
  root; it does not delete the subscription. Do not assume removal restores the
  previous parent. Inspect the provider's destroy plan before removing it.
- Renaming `name` replaces the group; changing a parent reparents it. Review
  effects on inherited controls. Deletion requires an empty group; this module
  deliberately has no hardcoded destroy guard. Use caller governance and plan
  review to protect foundational groups.
- Manage group membership, RBAC, policies, and subscription creation separately.
  Management groups are control-plane hierarchy objects, not network services
  with private endpoints.

## Import and verification

Import an existing group through its module address before trying to manage it:

```bash
terraform import 'module.platform_management_group.azurerm_management_group.management_group' \
  '/providers/Microsoft.Management/managementGroups/<existing-name>'
```

Associations also require import if already present; their import ID is
`/providers/Microsoft.Management/managementGroups/<name>/subscriptions/<uuid>`.
Review a fresh plan after import. Do not apply over resources owned by other state.

From this directory, `terraform init -backend=false`, `terraform validate`, and
`terraform test` run local schema validation and mocked plan tests without Azure
credentials. Mocked tests do not verify actual tenant permissions or Azure behavior.
Reusable modules declare compatible version bounds; the caller pins exact versions
and owns its lock file. A standalone module init may create an incidental lock file.

## References

- [Management group resource](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/management_group)
- [Subscription association resource](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/management_group_subscription_association)
