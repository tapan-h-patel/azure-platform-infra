# Terraform state storage

Reusable implementation behind bootstrap/tfstate. Calls resource-group, then
creates the StorageV2 account, private container and group-scoped blob role
assignments. Provider authentication and backend configuration stay in the root.

Inputs match the bootstrap interface: tenant_id/subscription_id (backend output
metadata only), location, naming, allowed_public_ipv4_addresses,
state_group_object_ids, optional replication_type (ZRS) and tags. Outputs:
resource_group_name, storage_account_name, container_name, backend_configuration.
See ../../bootstrap/tfstate/README.md for configuration, access and recovery details.

This extraction preserves the user's current resource settings, including the
disabled prevent_destroy lifecycle settings on the account/container. The resource
group module also has no deletion guard. Private endpoint support and storage
public-access lockdown are separate work; this module still uses the public IP
allowlist. No new storage resource was deployed as part of this refactor.
