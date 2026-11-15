# Architecture

## ALZ adoption configuration

An alternative Azure DevOps bootstrap is prepared under alz/azure-devops; the
platform tfvars and library are separate copies that must be kept synchronized.

The [alz folder](../alz/README.md) contains official-accelerator bootstrap and
platform inputs with the custom hierarchy and a selected observe-first policy
baseline. This is a local draft, not a deployed replacement for the existing
roots. Storage reuse, Observability provider mapping, access/runner extensions
and lifecycle separation remain explicit implementation work. The management
resource deployment is disabled in the draft to avoid placing logs in the wrong
subscription; it does not establish monitoring until that adaptation is complete.

## Boundaries

- bootstrap/tfstate: independently managed state storage and access.
- foundation/management-groups: tenant hierarchy plus security groups and scoped
  role assignments; separate customer foundation state.
- foundation/subscriptions: navigation only; platform and workloads/dev, uat, prod
  contain independently operated module-only subscription-vending roots and state.
- platform: navigation by shared responsibility (connectivity, identity,
  management, observability, security).
- workloads: navigation by workload environment (dev, prod, uat).
- environments/lab: earlier scaffold retained until deployment placement is decided.
- modules: reusable building blocks with no backend or authentication embedded.
- Deployment roots compose module calls; all resource declarations live under
  modules. Resource groups use modules/resource-group. Bootstrap uses the composed
  modules/tfstate-storage, preserving its inputs and outputs.
- aks-git-ops owns Kubernetes configuration; app1 owns application source/builds.

The platform/workloads folder hierarchy is for navigation only. It does not
automatically create Terraform roots, state files, or Azure deployment scopes.
Choose those boundaries as deployments are implemented. Existing configurations
remain in place, and hierarchy creation stays in foundation/management-groups.

## Hierarchy and access

Tenant Root is existing/unmanaged. The intermediate root contains Platform and
Workloads. Platform has Connectivity, Identity, Management, Observability, Security.
Workloads has Dev, Prod, UAT. The example creates 11 scopes, 33 security groups,
and 33 bindings (77 resources). Nothing is created on Tenant Root itself.

management-group-with-access composes management-group and scope-access. Explicit
root/branch/leaf calls express dependencies. Names, IDs, role maps and group owners
are customer inputs. Entra groups bind by object ID to scope IDs. Membership is
managed externally and ignored by Terraform; owners and assignments are managed.
Role inheritance and Owner privilege require deliberate governance. PIM, policies,
SP creation, federation and approval automation are not implemented.

No subscription moves are managed here. The user will place the lab subscription
in Management after recreation. Existing test groups will be removed by the user,
not imported. The base module's association feature remains separately available.
No new foundation deployment has been run by the agent.

## Bootstrap and versions

The user tested bootstrap with LRS and destroyed it. Replication is an explicit
root input (the example uses ZRS). Storage has a restricted public endpoint, disabled shared keys,
versioning and 30-day soft delete. Private endpoints, DNS and operator connectivity
are planned before shared state use. Management groups/RBAC are control-plane
objects without private endpoints. Recovery drills have not been performed.

Roots pin Terraform 1.17.2 and AzureRM 5.14.0. Foundation also pins AzureAD 3.9.0.
Root lock files are retained; reusable modules declare compatible bounds. The
lab location is uksouth with naming token uks. See naming-convention.md,
accelerator-design.md and access-model.md. Regional sizing, private networking,
production recovery controls, policy and GitOps integration remain future work.

## Foundation backend

The management group root configures its azurerm backend directly in backend.tf,
including the lab storage account sttfstateshareduksplt001, container tfstate,
and key azlab/foundation/management-groups.tfstate. No separate backend.hcl is
required. Entra/Azure CLI authentication avoids embedded credentials. Customer
copies must edit the backend literals before initialization; reusable modules
remain independent of customer settings. Fresh provisioning writes state to
Azure from the beginning. Existing live local state must not be abandoned.
The account currently uses a default-deny public endpoint with no private endpoint.
Private networking is still pending. No state migration was executed by the agent.

## Self-hosted CI/CD foundation

Local Terraform now defines a dedicated runner VNet, delegated ACA subnet,
separate private endpoint subnet, state blob endpoint/DNS and an internal ACA
Consumption-profile environment. These have separate connectivity and management
deployment roots; no Azure deployment has been run. Network CIDRs and resource IDs
are customer inputs. Storage public access is unchanged pending private-path tests.
Actual jobs, images, registration, OIDC identities, monitoring and workflows remain
future work. The repository is public, so untrusted fork PRs must not enter private
runners. See [CI/CD design](ci-cd-design.md) for the staged rollout and trust choices.

Self-hosted runner work is currently on hold at the user's request. No runner
infrastructure files were changed by the subscription vending implementation.

## Subscription vending

modules/subscription-vending creates a subscription alias under a supplied EA,
MCA or MPA billing scope and associates the returned subscription UUID with an
existing management group. foundation/subscriptions/platform repeats it for Connectivity,
Identity, Management, Observability and Security. Each entry supplies names,
billing scope, workload classification, tags and target ID through terraform.tfvars.
A visible MCA invoice section has been populated in ignored local inputs; actual creation eligibility/permissions remain unconfirmed.
No subscription has been created by this work. Post-creation tenant verification,
prevent_destroy and provider cancellation protection are included. Placement can
fail independently of creation, so preserve state and review recovery plans.
The hierarchy root remains separate; the vending root alone owns new associations.

The subscriptions root backend is configured directly with its separate key azlab/foundation/subscriptions.tfstate and has initialized successfully. Read-only billing discovery found an MCA account, billing profile and invoice section; no subscriptions have been provisioned by the agent.

The original vending root moved into foundation/subscriptions/platform, preserving
that existing backend key and all resource addresses. No remote state migration
was performed. New workload roots under workloads/dev, workloads/uat and
workloads/prod each use a distinct azlab/foundation/subscriptions/workloads/<env>.tfstate
key, their own tfvars and matching management group. Each can be planned/applied
independently. The parent subscriptions directory is no longer a deployment root.

## Hub-and-spoke connectivity

The new platform/connectivity/hub-spoke root composes reusable resource-group,
vnet, vnet-peering, route-table and azure-firewall modules through modules/hub-spoke.
It has a separate backend key and tfvars inputs. One provider currently deploys
the hub and all spokes in one subscription; cross-subscription composition needs
explicit provider aliases in future roots. No connectivity deployment has run.

Bidirectional hub/spoke peerings allow forwarded traffic but do not assume gateway
transit. Workload tables route default/private prefixes, managed spoke prefixes and
managed workload subnet prefixes through the hub firewall's computed private IP.
Hub workload tables supply the symmetric return path. Reserved infrastructure
subnets, including AzureFirewallSubnet, are excluded. CIDR overlap/containment and
firewall subnet sizing are checked. The initial firewall policy is default-deny
until reviewed network allow rules are supplied. DNS integration, NSGs, diagnostics,
VPN and service-specific private endpoint routing remain separate work.

## Governed vending target

The [governed vending design](subscription-vending-design.md) defines the target
common baseline and connected/isolated profiles, staged readiness, and independent
central connectivity/governance/logging ownership. Current subscription roots
implement creation/placement only. Identity was created by the user and placed
under mg-identity; its existing creation state and alias must be preserved while
adding the baseline. Remaining subscriptions are subject to billing restrictions.

The user has not reviewed/deployed the single-subscription hub-spoke reference.
The target connected profile uses central AVNM/IPAM with spokes in their own
subscriptions. The reference's static CIDRs/manual peerings do not implement that
service. No networking configuration or live state was changed during design work.
