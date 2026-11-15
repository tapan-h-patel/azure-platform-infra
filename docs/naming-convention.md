# Azure resource naming convention

Use this convention when adding Terraform resources to this repository.

The values below describe the initial lab. For customer deployments, supply the
workload/customer identifier, environment, region token, and tags as configuration.
Do not hardcode `azlab`, `lab`, or `uks` into reusable modules. Where a customer
has an established naming policy, document and configure that mapping explicitly.

## Standard pattern

```text
<resource-type>-<workload>-<environment>-<region>-<instance>
```

| Component | Lab value | Purpose |
|---|---|---|
| Resource type | See examples below | Identifies the Azure resource type |
| Workload | `azlab` | Identifies the Azure platform lab |
| Environment | `lab` | Distinguishes environments; future examples include `dev`, `test`, and `prod` |
| Region | `uks` | Repository abbreviation for Azure location `uksouth` |
| Instance | `001` | Three-digit identifier, incremented for additional resources of the same purpose |

Use lowercase names. Keep identifiers stable throughout a resource's lifetime.
The region abbreviation is a naming token; use `uksouth` for Terraform location
arguments.

## Platform examples

| Resource | Name |
|---|---|
| Platform resource group | `rg-azlab-lab-uks-001` |
| Virtual network | `vnet-azlab-lab-uks-001` |
| AKS subnet | `snet-azlab-lab-uks-aks-001` |
| AKS cluster | `aks-azlab-lab-uks-001` |
| Log Analytics workspace | `log-azlab-lab-uks-001` |

For resources dedicated to a particular purpose, insert the purpose before the
instance, as shown by `aks` in the subnet name. Use the same purpose consistently
in related Terraform configuration.

## Hub-and-spoke networking

Names are explicit tfvars values. Example: vnet-azlab-hub-uks-001,
vnet-azlab-management-uks-001, rt-azlab-management-uks-001,
afw-azlab-hub-uks-001, afwp-azlab-hub-uks-001 and pip-azlab-firewall-uks-001.
Peering names express direction, for example peer-hub-to-management and
peer-management-to-hub. The Azure-required firewall subnet name is
AzureFirewallSubnet; ordinary workload subnets use the snet naming prefix.

## Management groups

Management groups span regions and can span environments. Use
`mg-<customer-or-workload>-<purpose>` rather than the regional resource pattern,
for example `mg-example-platform` and `mg-example-connectivity`. Their stable IDs
must be unique within the customer tenant. Use friendly display names separately.
The module accepts 1-90 lowercase letters, digits, and hyphens, starting with a
letter or digit. Management groups do not support Azure resource tags or location.

## Terraform state resources

State storage uses workload `tfstate` and environment `shared` because it can
serve multiple platform environments.

| Item | Name or pattern |
|---|---|
| State resource group | `rg-tfstate-shared-uks-001` |
| Storage account | `sttfstateshareduks<suffix>` |
| State container | `tfstate` |
| Lab state blob key | `azlab/lab/terraform.tfstate` |

The blob key identifies the lab's state within the container. The bootstrap
root's own state location and key will be decided separately.

## Compact names and uniqueness

Use the compact pattern for storage accounts and Azure Container Registry:

```text
Storage account: sttfstateshareduks<suffix>
Registry:        acrazlablabuks<suffix>
```

`<suffix>` is a placeholder, not literal text. Choose a stable, lowercase
alphanumeric suffix when implementing these resources, and retain it on later
runs. Do not regenerate it on each deployment. These patterns replace the
standard hyphenated instance component with the uniqueness suffix.

The bootstrap currently requires each compact naming token, including the suffix,
to start with a lowercase letter, followed by lowercase letters or digits. Its
combined storage account name must fit within 24 characters. Example suffix:
`abc123`. It validates the instance as three digits.

Check the target resource's naming constraints and name availability before
deployment. A naming pattern alone does not guarantee global uniqueness.

## Tags

Apply these baseline tags to platform resources that support tagging:

```hcl
workload    = "azlab"
environment = "lab"
managed_by  = "terraform"
repository  = "azure-platform-infra"
```

For shared state resources, use `workload = "tfstate"` and
`environment = "shared"`. Keep ownership and other descriptive metadata in tags
rather than expanding resource names. Additional tags can be agreed as needed.

## Applying the convention

1. Select the resource prefix, workload, environment, and region token.
2. Add a purpose token only when it helps distinguish the resource.
3. Select a stable instance number or compact uniqueness suffix.
4. Check naming constraints for the resource type.
5. Apply the corresponding baseline tags.

Document new prefixes or exceptions here when introducing them. Review name
changes carefully: renaming an existing Azure resource can require replacement.

## Subscriptions

Subscription display names follow sub-<customer>-<purpose>-<environment>-<instance>,
for example sub-azlab-management-shared-001 or sub-azlab-workloads-dev-001.
Use shared for cross-environment platform services. Omit region because subscriptions
may span regions. In subscription vending, aliases are explicit stable identifiers;
the initial example uses the same string as the display name. Keep aliases stable:
changing them is not the same as renaming a display name. Azure assigns subscription
UUIDs; never use the alias resource ID as a subscription resource ID.

## Runner infrastructure

Runner components use a caller-supplied stable stem such as example-lab-uks-001.
Initial prefixes are rg-runner-network, vnet-runners, snet-runners,
snet-private-endpoints, pe-tfstate-blob, rg-runners and cae-runners, followed by
that stem. Private blob DNS uses the service-required zone
privatelink.blob.core.windows.net. These purpose-first names are an explicit
exception to the general pattern for this runner infrastructure.

## Scoped security groups

Use grp-<scope-name>-<scope-type>-<role>, for example grp-platform-mg-reader, grp-sub1-sub-reader, or grp-networking-rg-owner. Tokens are mg, sub, rg and resource. Access naming tokens must be unique within the tenant deployment. Roles default to reader, contributor and owner. See [access model](access-model.md).
