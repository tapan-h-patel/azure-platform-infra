# Scope-based access

Scopes and their baseline access are composed together. Every new management
group gets these default groups and bindings at its own scope:

| Name | Azure role |
|---|---|
| grp-<scope>-mg-reader | Reader |
| grp-<scope>-mg-contributor | Contributor |
| grp-<scope>-mg-owner | Owner |

Other naming tokens are sub, rg, and resource. Scope-access is reusable for those
explicit scopes, but provisioning callers for them is future work. Roles are
configurable. Reader/Contributor/Owner do not universally grant data-plane access;
add narrowly scoped data roles separately when required.

People gain access through group membership. Terraform creates groups and role
bindings and manages owners; membership is intentionally ignored so the identity
administration process can add/remove members. Owners can grant access through
membership, so protect their identities. Owner status itself is not membership.
Groups start empty. Service principal membership must be explicitly governed;
avoid mixing automation and human access by default.

Assignments inherit downward; leaf roles cannot reduce inherited access. Owner
allows access administration. No PIM, approvals, emergency access, or compliance
guarantee is implemented. Managed identity membership changes can take many hours
to propagate: [Microsoft guidance](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identity-best-practice-recommendations).

AzureAD manages directory objects while AzureRM manages scopes/role assignments.
Their permissions are independent prerequisites. Destroying the composition
removes its groups and bindings, including operational membership. Review both
identity and Azure access effects before changing or destroying resources.

## Subscription vending integration

The [vending design](subscription-vending-design.md) places subscription security
groups and role bindings in the future baseline stage. Management group grants
remain inherited rather than copied. Group membership remains externally managed;
automation federation and scoped stage permissions are separate capabilities.
The current scope-access module creates standing roles, not PIM eligibility.
