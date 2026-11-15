# Management group with access

Composes management-group with scope-access to provision a management group and
its scoped security groups/role assignments together. Plain group creation remains
available independently through the base module.

Inputs: name, display_name, parent_management_group_id, access_name,
group_owner_object_ids. Optional roles defaults to Reader, Contributor and Owner
with lowercase naming keys; callers can reduce or empty the map. Outputs: id,
parent_management_group_id and groups (role-keyed access details).

Names follow grp-<access_name>-mg-<role>. Providers/authentication and owner IDs
come from the caller. No backend, customer IDs, subscriptions, memberships, policy,
or SP creation is embedded here. Groups start empty; external membership changes
are ignored. Terraform owns group owners and bindings. Destroy removes those
groups and bindings; review access dependencies before deletion. Permissions for
Graph group creation, management group creation, and Azure RBAC are all required.
See ../../foundation/management-groups/README.md for the deployable example.
