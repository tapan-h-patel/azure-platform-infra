# State bootstrap

This deployment root now calls modules/tfstate-storage, which composes the
resource-group module and state storage resources. Inputs and root outputs remain
the same. After pulling this refactor, run terraform init before planning.
The moved.tf declarations map previous addresses into modules; keep them for
existing states. Review a fresh plan to confirm moves rather than replacements.

Creates a resource group, StorageV2 account, private `tfstate` container, and
container-scoped Storage Blob Data Contributor assignments for explicit Entra
security groups. This root initially uses local state. The user tested deployment
with LRS and then destroyed it. The example uses ZRS; explicitly supply replication
explicitly for each deployment. Private endpoint support is planned but not yet
implemented; the current configuration uses a restricted public endpoint.

## Versions and authentication

Use exactly Terraform 1.17.2 and AzureRM 5.14.0. Versions are pinned for repeatable
deployments; upgrades require explicit version changes and validation.
Retain the generated `.terraform.lock.hcl` in Git.

Run Terraform and Azure CLI in the same Ubuntu WSL session. Use a native Linux
Azure CLI installation if Windows CLI interop causes token or executable issues.
This root does not store credentials. Federated automation identity is future work.

## Prerequisites

- An authenticated Azure CLI user in the target tenant and subscription.
- Permission to create resource groups and storage resources, and permission to
  create the specified role assignments. Contributor alone cannot assign roles.
- Microsoft.Storage registered in the subscription. Automatic provider
  registration is disabled to avoid broad subscription changes; ask a subscription
  administrator to register it if needed.
- A stable, available storage account name and supported replication/location.
- The operator's public IPv4 egress address, including any VPN/proxy egress.
  Azure Storage firewall IP rules do not provide the same behavior for clients
  hosted in the same Azure region; those need an appropriate network design.
- Existing Entra security groups for state access, with operators as members.
  Supply group object IDs, not user IDs or display names. Group creation and
  membership are managed separately; this root does not modify the directory.
  Directory read permission is required for the lookup below. If unavailable,
  ask the identity administrator for the verified group object ID.

Resolve a group by name using [Azure CLI group lookup](https://learn.microsoft.com/en-us/cli/azure/ad/group#az-ad-group-show):

```bash
az ad group show --group "<state-access-group-name>" \
  --query '{name:displayName,id:id,securityEnabled:securityEnabled}' -o json
```

Verify the full name, tenant, and `securityEnabled = true`. Names can be ambiguous;
ask the identity administrator to identify the correct object if multiple groups
match. Put its stable `id` into `state_group_object_ids`. Azure RBAC assignments
use object IDs; a display name is a lookup aid, not the assignment identity.
After membership changes, allow propagation and refresh your Azure CLI sign-in
before testing access. Bootstrap deployment permissions remain separate from
this container's state data access.

If you copied an earlier example, replace `state_principal_ids` with
`state_group_object_ids` in your ignored local `terraform.tfvars`, and replace any
individual user IDs with group IDs. Do not merely rename a user ID's input key.

## Configure and validate in WSL

From the repository root:

```bash
cd bootstrap/tfstate
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`: replace all example IDs, IPs, and the uniqueness suffix.
Use your subscription/tenant IDs, `uksouth`, and the agreed naming tokens for the
lab. Preserve the suffix across runs. Customer deployments supply their own values.
The example IP is reserved for documentation and will not grant usable access.

```bash
az account show --query '[id,tenantId,name]' -o tsv
terraform init -backend=false
terraform fmt -check
terraform validate
```

Verify the CLI tenant/subscription against your configuration before proceeding.
If needed, explicitly select the subscription with `az account set --subscription
<subscription-id>`. Do not paste credentials into configuration files.

When ready for a separate plan review:

```bash
terraform plan -out=bootstrap.tfplan
```

No apply is required for validation. Only after explicit approval and plan review,
run `terraform apply bootstrap.tfplan`. Plans and local state are sensitive,
ignored files; protect them on disk and remove obsolete plans securely.

## Security and recovery choices

- HTTPS required, TLS 1.2 minimum; Azure-managed encryption at rest.
- Shared key authentication and anonymous blob access disabled.
- Public endpoint enabled with default-deny firewall and explicit IPv4 allowlist;
  trusted-service bypass is disabled. This is not a private-endpoint deployment.
- Replication is explicit in terraform.tfvars; the example selects ZRS. Review
  regional availability and cost before choosing a value.
- Blob versioning plus blob/container soft delete with 30-day retention.
- The current user configuration has `prevent_destroy` disabled for the account
  and container, and the resource group module has no deletion guard. The module
  extraction preserved these settings; do not assume Terraform prevents deletion.
  These guards do not prevent portal deletion and do not survive removal of their
  resource blocks from configuration. No Azure management lock is created yet.
- Data access is granted only to supplied groups, at container scope. Role
  propagation can take time; retry authentication after propagation rather than
  enabling shared keys. Avoid concurrent operations while diagnosing access.

Storage account creation can require data-plane reads for blob settings. Ensure
the operator IP is allowed before applying. If the IP changes, update the allowlist
through an authorized management-plane path. Private endpoints, diagnostics,
customer-managed keys, policy integration, and recovery drills remain future work.
Versioning is not an independent backup; old versions can also incur storage costs.

## State migration after deployment

1. Keep a secure backup of the initial local state and stop concurrent operations.
2. Verify Entra data access and firewall connectivity from the operator session.
3. Obtain non-secret backend settings with `terraform output backend_configuration`.
4. Create an ignored `backend.hcl` with those settings and a unique key, such as
   `tfstate/shared/bootstrap.tfstate`. Add `terraform { backend "azurerm" {} }`
   in a new `backend.tf` for this root only after storage exists.
5. Run `terraform init -migrate-state -backend-config=backend.hcl`, review the
   migration prompt, and verify `terraform state list` against the remote backend.
6. Retain protected backups until migration is verified. Do not use `-reconfigure`
   as a substitute for migrating local state.

Use a different key, `azlab/lab/terraform.tfstate`, for the lab root, with its own
backend configuration. Do not share backend state across customer boundaries.
The Azure backend uses blob leases for locking; never force-unlock without first
confirming that no operation owns the lease.

For recovery, stop writers, identify the affected blob/version or deleted container,
and use Azure recovery tooling with authorized access. Preserve a copy before
restoration, then check `terraform state list` and review a fresh plan. Do not apply
an older saved plan after restoring state. Test this process before customer use.

## References

- [AzureRM storage account](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/storage_account)
- [AzureRM storage container](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/storage_container)
- [Azure backend authentication and locking](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [Azure Storage firewall limitations](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security-limitations)
