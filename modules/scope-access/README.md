# Scope access

Creates one cloud security group and one Azure RBAC binding per role at an explicit
scope. Does not create the scope or manage group membership, SPs, credentials, or PIM.

Required inputs: scope (full ID), scope_name (unique naming token), scope_type
(mg/sub/rg/resource), group_owner_object_ids (nonempty user/SP UUID set).
Optional roles maps naming suffixes to built-in role names; defaults to the three
reader/Reader, contributor/Contributor, owner/Owner entries. Empty creates nothing.
Output groups contains object_id, display_name, role_name, scope and assignment ID.

Names follow grp-<scope_name>-<scope_type>-<role-key>. The caller must supply the
correct type for its scope; automatic resource/subscription integration is not
implemented. Both providers are inherited. AzureAD >=3.9,<4 and AzureRM >=5.14,<6
are supported bounds; callers pin exact versions and own lock files.

Groups are empty at creation. Membership is ignored by lifecycle rules, allowing
external administration without reconciliation. Owners and role bindings remain
Terraform-managed. Owners control membership and are privileged. No auto-enrollment
or default owner is selected. Duplicate display names fail instead of adoption.

Deleting/replacing groups removes access and operational membership. Owner is a
powerful standing Azure role; roles can be reduced by caller policy. Parent access
inherits downward. Graph group creation permissions and Azure assignment permissions
are separate. See ../../foundation/management-groups/README.md for setup.
