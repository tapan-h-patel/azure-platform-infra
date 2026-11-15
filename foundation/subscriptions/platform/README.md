# Platform subscription vending

Separate deployment root/state for new platform subscriptions. Root files contain
only module composition, variables/outputs and provider/backend configuration.
All subscription names, aliases, billing scopes, workload types, tags, and target
management group IDs are supplied through terraform.tfvars.

The example maps five new subscriptions to five existing scopes:

| Area | Subscription display name example | Management group example |
|---|---|---|
| Connectivity | sub-example-connectivity-shared-001 | mg-example-connectivity |
| Identity | sub-example-identity-shared-001 | mg-example-identity |
| Management | sub-example-management-shared-001 | mg-example-management |
| Observability | sub-example-observability-shared-001 | mg-example-observability |
| Security | sub-example-security-shared-001 | mg-example-security |

Each entry calls modules/subscription-vending. With all five entries, the expected
creation plan is ten resources (five aliases/subscriptions and five associations).
Management groups must already exist. Their inherited role bindings apply to the
new subscription; no subscription-level access groups or role bindings are created.
The existing lab/free subscription is not moved or adopted. The new Management
subscription is separate from any existing subscription manually placed there.

## Configuration and billing prerequisites

Use Terraform 1.17.2 and AzureRM 5.14.0. Set tenant_id and an existing
 deployment_subscription_id for provider authentication. This provider subscription
is not a request to create or move it. subscriptions is a map keyed by stable area
identifiers; each entry requires alias, subscription_name, billing_scope_id,
management_group_id, workload and tags. Output subscriptions returns created IDs
and placement keyed by area. Do not change map keys after deployment without a
reviewed state-address move.

EA, MCA and MPA billing scope shapes are supported and can differ per entry. The
billing agreement must actually support API subscription creation, and the caller
must have the corresponding billing rights as well as management group placement
rights. Azure resource roles alone do not grant billing rights. Use the real
billing scope from the billing administrator; do not infer it from a subscription
ID, tenant ID or resource group. See the [module guide](../../../modules/subscription-vending/README.md).

Copy terraform.tfvars.example to ignored terraform.tfvars for each customer and
replace every placeholder. The prepared local lab file contains the known lab
IDs and mg-* targets. An MCA billing account/profile/invoice section was discovered
through read-only Azure CLI queries and populated into the ignored local tfvars.
Visibility of a billing scope does not prove subscription-creation eligibility.
The tracked example is sanitized and should never receive live billing details.
Production is a billing workload classification here, not a claim that the lab
is a production environment. Confirm DevTest eligibility before selecting it.

## Local validation and review

```bash
cd foundation/subscriptions/platform
terraform init
terraform validate
terraform test
# After valid billing inputs and backend setup:
terraform plan -out=subscriptions.tfplan
```

The tests mock Azure; they do not call billing APIs or spend money. No subscription provisioning has been run by the agent. Review billing scope,
expected charges, tenant ownership, names and management group placement before
any apply. Do not execute a saved plan from an unrelated state or previous inputs.

The lab Azure Blob backend is configured directly in backend.tf, using Entra
authentication and key azlab/foundation/subscriptions.tfstate. Customer copies
must update those explicit backend values before initialization. Never
reuse the management-group or bootstrap state key. Backend blocks cannot consume
Terraform variables. Remote backend initialization has succeeded for the lab; keep
it and plan files protected and outside Git. Migrate any existing state deliberately
rather than reconfiguring away live subscription ownership.

## Recovery and lifecycle

prevent_destroy on the module's subscription and provider cancellation protection
are intentional. A subscription is a billing boundary; decommissioning needs a
separate reviewed process. A failed placement may leave a newly created subscription
at the tenant/default management group; creation/association are not atomic.
Keep the state, resolve permissions/propagation and review a fresh plan. Do not
start again with a new alias, remove state, or create a duplicate subscription.
If a remote creation succeeds but fails before being recorded, reconcile the
existing alias before retrying; do not assume every failure rolled back.

Moving subscriptions changes inherited access and policy. Do not manage the same
association in foundation/management-groups or the portal while this root owns it.
No automatic budgets, resource registrations, SP creation, workload deployment or
PIM controls are included. The paused self-hosted runner work is independent.

Authentication tenant_id and expected subscription_tenant_id are separate inputs for billing flexibility. They are normally equal for a direct customer but may differ in eligible partner setups. The expected tenant only verifies creation; it does not select or transfer the tenant. Follow the billing agreement's home-tenant identity and customer authorization requirements.

## Lab test result

Validation and eight mocked tests pass. A real Azure-backed plan completed with 10 additions, no changes and no deletions: five subscriptions and five management group associations. The MCA invoice section is recorded only in ignored local tfvars. Billing creation eligibility is still determined at apply; no subscriptions were created. The plan was generated with Windows Terraform 1.17.2; regenerate it in the WSL execution environment before applying there. The readable subscriptions.tfplan.txt export is ignored by Git.

## Folder relocation

This root moved from foundation/subscriptions to foundation/subscriptions/platform. Its remote backend key remains azlab/foundation/subscriptions.tfstate and module addresses are unchanged. No remote state migration is required for this folder-only move. Run terraform init and regenerate the plan here; do not apply a saved plan from before the restructure. Workload subscription creation is isolated in sibling workload environment roots.

## Partial lab apply and billing limits

The user applied this root. Identity creation succeeded in Azure (alias
sub-azlab-identity-shared-001); Connectivity, Management, Observability and
Security timed out during AliasCreate after 30 minutes. A subsequent read-only
Azure alias list returned only Identity. Do not reuse the pre-apply plan or
remove its state. Verify terraform state list and the existing alias before retrying.

Microsoft documents one creation per 24 hours, a maximum of five subscriptions,
and account-history eligibility for MCA purchased directly through Azure.com.
That is a plausible explanation here, not confirmed by the generic timeout.
Confirm the billing purchase channel and limits with Azure Billing Support.
Do not work around this by changing aliases, clearing state, merely increasing
timeouts or repeating the full apply. The bulk-vending template remains reusable
for eligible agreements/accounts; it cannot override account billing limits.
