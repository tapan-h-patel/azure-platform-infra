# Subscription vending

This is the creation/placement building block, not the complete delivery service.
The [governed vending design](../../docs/subscription-vending-design.md) describes
the future baseline/profile composition. Preserve existing alias/state ownership
when adding stages; do not replace an already created subscription.

Creates a new Azure subscription using an explicit billing scope and stable alias,
then places it in an existing management group. It does not create billing
agreements, management groups, users, Entra groups, policies or workload resources.
The caller supplies authentication and its own backend.

## Inputs and outputs

All inputs are required: alias, subscription_name, billing_scope_id,
management_group_id, workload, expected_tenant_id and tags. The alias is a stable
creation identifier and must not be generated afresh per run. subscription_name is
the friendly portal name; use sub-<customer>-<purpose>-<environment>-<instance>.
workload is Production or DevTest; the latter requires an eligible billing offer.

Outputs are subscription_id (UUID), subscription_resource_id (/subscriptions/UUID),
alias_resource_id, subscription_name, management_group_id and tenant_id. The alias
resource ID is not the subscription resource ID: the association uses the new
subscription UUID explicitly.

## Supported billing scope shapes

| Agreement | billing_scope_id shape |
|---|---|
| EA | /providers/Microsoft.Billing/billingAccounts/<account>/enrollmentAccounts/<enrollment> |
| MCA | /providers/Microsoft.Billing/billingAccounts/<account>/billingProfiles/<profile>/invoiceSections/<section> |
| MPA | /providers/Microsoft.Billing/billingAccounts/<account>/customers/<customer> |

The same module accepts all three; no code change or agreement-type switch is
required. Validation checks shape, not eligibility or permissions. A real billing
agreement and an authorized creation principal are prerequisites. An existing
Azure Free subscription or management group Owner role is not evidence of billing
creation rights. Use the billing identity's appropriate home tenant for provider
authentication; eligible partner arrangements can have a different expected
subscription tenant. The billing API determines tenant placement; the expected
tenant input only checks the result. Tenant transfers/consent are not automated.
A postcondition checks the returned tenant, but only after creation; it cannot
undo an incorrectly billed/tenanted subscription. Verify ownership before apply.

## Lifecycle and access

The subscription has prevent_destroy enabled. The deployment root also enables
the provider's prevent_cancellation_on_destroy feature. Do not remove these
protections as a routine cleanup step. Subscription destruction is not ordinary
resource cleanup and may cancel the subscription. Removing configuration/state
is not a safe decommissioning process; review billing, aliases and ownership first.
Changing alias/workload can require replacement and must be reviewed deliberately.

This module owns the new alias and management group association. Do not also
manage that placement through inline subscription_ids or another Terraform root.
Removing an association can reparent a subscription; no previous parent is
remembered. Billing and Azure hierarchy access are separate prerequisites, including
permissions on source/destination scopes and the subscription for placement.
Creation and permission inheritance can take time; preserve state after partial
failure and generate a fresh recovery plan rather than recreating subscriptions.

Existing management group access groups inherit into the subscription. This module
does not create extra subscription-level groups, assignment identities, budgets,
resource-provider registrations, policies, diagnostic settings, or deployment
credentials. Add those as separately composed modules when requirements are agreed.
No existing subscription is adopted by this create-only interface.

Compatible versions: Terraform >=1.17.2,<2 and AzureRM >=5.14,<6. Root callers pin
exact versions. Mocked tests exercise plan wiring, accepted billing scope formats
and invalid inputs without creating subscriptions; they do not prove billing API
eligibility, authorization, offer availability, propagation or real cancellation.

References:
- [Azure subscription resource](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/subscription)
- [Microsoft subscription creation agreements](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription)

## Direct Azure.com MCA creation limits

Agreement support does not mean an unlimited creation rate. Microsoft documents
one subscription creation per 24 hours and a maximum of five for MCA accounts
purchased directly through Azure.com, with further creation eligibility dependent
on account history. This is specific to that purchase channel, not all MCA/EA/MPA
customers. Check current billing limits before batching new subscriptions.

The lab's user-run apply created the Identity alias successfully while the other
four requests timed out after 30 minutes during AliasCreate. A read-only Azure
alias query afterward returned only Identity. This is consistent with the direct
MCA restriction, but no explicit billing-limit error was returned, so the cause
is not confirmed. Do not simply extend timeouts or repeatedly submit creation.
Preserve Terraform state and aliases, verify tracked resources against Azure,
and resolve billing eligibility/rate limits before a reviewed recovery plan.
Serial execution alone does not bypass a 24-hour or account-count restriction.

[Microsoft subscription creation limits](https://learn.microsoft.com/en-us/azure/cost-management-billing/troubleshoot-subscription/create-subscriptions-deploy-resources)
