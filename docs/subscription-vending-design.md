# Governed subscription vending design

Status: target design for review, not an implemented landing zone service.
The subscription creation/placement primitive already exists. The wider baseline,
AVNM/IPAM integration, profiles and orchestration described here are not implemented.
No Terraform configuration or live state is changed by this design document.

## Outcome

Deliver a subscription that has its approved governance, access, logging, cost
controls and, where required, private connectivity ready for use. Creating an
alias or placing it in a management group is only the first stage.

One approved request should initiate the process and produce a delivery record.
Internally, staged plans/applies and separate privilege/state boundaries are
expected. Roots call reusable modules; customer deployment values come from
terraform.tfvars. Backend blocks, source paths and version pins remain explicit.
An empty subscription is not automatically a completed landing zone.

## Baseline and ownership

| Capability | Target behavior | Owner |
|---|---|---|
| Subscription | Create once with stable alias; verify expected tenant and billing scope | Existing subscription creation root/state |
| Placement | Attach to the approved management group | Same creation root; no second placement owner |
| Inherited governance | Verify expected parent assignments rather than duplicate them | Central governance root at appropriate management groups |
| Human RBAC | Create or reference subscription-scoped Reader/Contributor/Owner security groups and bind configured roles | Subscription baseline stage, composing scope-access |
| Membership | Manage membership outside Terraform; owners remain explicit privileged identities | Customer identity process; Terraform ignores member changes |
| Automation access | Scoped federated deployment identities, separate from human access | Platform identity/access configuration; exact permissions reviewed per stage |
| Tags | Customer, workload, environment, owner, cost centre and classification plus managed_by/repository | Request and baseline; resource tags require resource configuration or policy, not subscription tag inheritance |
| Activity Log | Configure subscription diagnostic export to approved central destination(s) | Subscription baseline stage |
| Resource logs | Deploy diagnostic settings for supported services via centrally selected policies | Central policy by default; never simultaneously own the same setting in resource Terraform |
| Budget | Set approved amount, period and alert recipients/thresholds | Subscription baseline stage |
| Providers | Register only the provider namespaces required by the selected profile | Subscription baseline stage; no blanket registration |
| Security services | Apply approved security posture; paid Defender plans require explicit customer selection | Central policy/security configuration and opt-in baseline settings |
| Network address space | Request an allocation from the approved AVNM IPAM pool | VNet allocation lifecycle, using central pools |
| Spoke | Create VNet/subnet/NSG baseline in the target subscription | Connected subscription baseline stage |
| Hub connection | Enroll the VNet in the approved AVNM network group and verify deployed connectivity | Central connectivity service/configuration |
| Routing | Apply approved hub-firewall routes, symmetric return routing and DNS integration | Central connectivity configuration and designated subnet route owner |
| Handover | Report readiness only after validation, with recorded dependencies/exemptions | Vending workflow |

Management group RBAC inherits. Subscription groups provide narrower grants;
they cannot reduce inherited privileges. Groups start empty and ownership is not
membership. The requested role pattern is configurable, not a reason to add every
user to Owner. Standing assignments, PIM eligibility and activation are different
designs. The current scope-access module implements standing assignments only;
do not advertise PIM as available. Azure RBAC groups need not be Entra directory
role-assignable groups. Do not grant directory administration simply to bind an
Azure resource role.

Budget alerts do not stop spending. Required limits/notifications and operational
responses must be explicit. Log destinations, retention, ingestion costs, security
plan costs and firewall/AVNM costs must be reviewed before enabling services.

## Profiles

| Profile | Common baseline | Networking |
|---|---|---|
| connected | Required | IPAM-backed spoke allocation, approved subnet layout and NSGs, DNS integration, AVNM hub connectivity, firewall routing and verification |
| isolated | Required | No automatic corporate/hub connectivity. Explicitly selected service-local networking/private endpoints are allowed; isolation does not mean public access is enabled |

Environment (dev/uat/prod) is independent of profile. A production subscription
does not automatically require broad corporate connectivity, and a development
subscription can require a connected profile. Default the intended platform and
workload connected subscriptions to connected only when their requirements justify
it. A customer without IPAM can use a separately approved static-allocation adapter;
do not silently fall back to handwritten CIDRs in an IPAM-backed request.

Platform bootstrap is an internal deployment phase, not a customer handover profile.
It can establish foundational subscriptions before central logging/connectivity
exist, but must remain marked baseline_pending. Finalize the common baseline after
shared services exist. Do not resolve this dependency by silently skipping logging
or marking a partially configured subscription ready.

## Shared services are established once

Connectivity owns regional hub(s), Azure Firewall/policy, AVNM scope/configurations,
IPAM pool hierarchy and shared private DNS/resolver integration. Observability owns
approved logging destinations and retention. Governance owns management group
policy/initiative assignments and remediation identities. Identity owns automation
federation and privileged ownership configuration. These resources are not recreated
by each subscription request.

Initial bootstrap order:

1. Establish management groups, baseline scope access and state bootstrap.
2. Create required platform subscriptions, honoring billing creation limits.
3. Deploy central logging, governance, hub/firewall, AVNM/IPAM and DNS dependencies.
4. Finish platform subscription baselines, including any Identity/Management spokes.
5. Vend workload subscriptions through the complete selected profile.

The exact policy/initiative IDs and versions, region lists, logging retention,
budget amounts and paid security services are customer configuration. They are not
universal constants. Deny policies must be tested against bootstrap prerequisites
before enforcement. Review audit/enforcement rollout and exemption ownership;
requests must not be able to disable mandatory governance with a free-form flag.

## Central IPAM and connectivity

Use AVNM IPAM as the allocation authority for the connected profile. Structure
pools by customer/routing domain and, where useful, region or environment. Register
existing on-premises, VPN and other cloud allocations/reservations before use.
Automatic nonoverlap is meaningful within the managed address plan, not unknown
networks. Delegate only required pool-use permissions.

A request selects an approved pool and capacity/prefix requirement. Create the VNet
with a service-backed allocation, then derive subnets from its returned address
space using an approved layout. Do not implement allocation by listing free ranges
and choosing one in a script; concurrent requests must not race. Allocation size,
pool exhaustion, release and change behavior need explicit validation. Retain the
allocation while its VNet exists; deleting/releasing it is a controlled network
lifecycle operation, not an incidental pipeline cleanup step.

Prefer AVNM as the connectivity owner for the target scaled design. Deploy its
approved hub-and-spoke configuration and enroll authorized spoke VNets. Disable
direct spoke connectivity/mesh where firewall transit is required. Do not permit
arbitrary workload tags or user-controlled network-group membership to bypass the
approval boundary. Network groups and deployment scopes need reviewed permissions.

AVNM-owned peerings must not also be managed by azurerm_virtual_network_peering.
IPAM, connectivity and routing are distinct capabilities. Hub firewall transit,
private DNS and effective route verification remain required; enrollment alone
does not prove a secure path. Select one owner for UDRs before implementation:
central Terraform route configuration initially, or an explicitly evaluated AVNM
routing configuration. Do not allow both to reconcile the same route tables.

The current all-in-one single-subscription hub-spoke root uses static CIDRs/manual
peerings and is an undeployed reference topology. It is not the target connected
vending implementation and must not be deployed as if it already implements AVNM,
IPAM or cross-subscription ownership. Existing low-level networking modules can be
reused after design review; no live networking needs migration today.

## Logging and Azure Policy

Activity Log export is subscription-level and part of the common baseline.
Resource logs are service-specific and require diagnostic settings as services
appear. Avoid representing an Activity Log export as complete workload logging.
Entra tenant audit/sign-in export is another scope and belongs to central identity
logging, not one identical export per subscription. Agent/data-collection rules,
VM guest logs and application telemetry are separate integrations where required.

The target default is policy ownership of supported resource diagnostic settings.
Resource modules must not create the same settings independently. If a customer
chooses module-owned diagnostics instead, the corresponding policy should audit
the requirement rather than deploy a competing configuration.

For deployIfNotExists/modify assignments, define a managed identity and least-
privilege remediation role bindings. A policy assignment alone does not remediate
existing resources. Establish remediation tasks and verify outcomes where required.
Inheritance and compliance are asynchronous; the workflow must distinguish pending
evaluation from failure, rather than immediately asserting full compliance.

Central policy should carry reusable guardrails at management group scope.
Subscription-specific assignments must be justified, and exemptions need an owner,
reason, expiry and approval. Do not replicate every inherited initiative at each
subscription. Policy assignments, enforcement modes and paid effects are versioned
platform configuration. Evaluate deny/modify effects against the existing lab
before any rollout; do not make unreviewed live assignments.

Log ingestion/export paths are service-specific. Private endpoints on a workspace
or storage account do not automatically privatize every Azure platform export.
Validate each service's supported network path before claiming private-only logging.

## Stages, identities and state

One request can orchestrate several separately reviewed plans/applies:

1. Validate request/profile, business ownership, billing rights, capacity and
   referenced platform dependencies. Record the immutable request key/version.
2. Run the existing creation/placement root. Persist its alias and returned
   subscription UUID; wait for subscription/access readiness.
3. Execute a baseline root with that known subscription UUID configured as its
   provider target. Create scoped access, Activity Log export, budgets/provider
   registration, and approved subscription-specific governance.
4. For connected requests, allocate/create the spoke, enroll connectivity, apply
   routes/DNS and validate the path using central connectivity permissions.
5. Produce a delivery record and hand over only after required checks pass.

The existing creation roots and their state keys remain in place. A baseline gets
separate ownership/state per subscription, and central hub/IPAM/policy/logging each
retain their independent state. The baseline root directory convention will be
chosen when implementing that stage; this design does not move existing roots.
Pass specific nonsecret IDs via explicit stage outputs/inputs, not unrestricted
access to every central state file. Backend settings stay directly in backend.tf.

A freshly created subscription ID cannot be treated as a dynamic Terraform provider
alias for arbitrary for_each subscriptions in the same AzureRM apply. Stages let
the next root initialize its provider using a known ID. Subscription provisioning,
billing permissions, directory permissions, central network configuration and
resource deployment are separate privilege boundaries. Prefer OIDC identities and
avoid giving application pipelines permission to change the shared hub or billing.

Readiness is not a fixed sleep. Use bounded status/authorization checks and record
failures without creating new aliases. Preserve partial state and existing IPAM
allocations; inspect Azure after API timeouts before retries. Account-specific
creation limits still apply and are not bypassed by this workflow.

## Request and handover contract

See [the illustrative connected request](examples/connected-subscription.tfvars.example).
It describes the intended input contract, not a file accepted by current roots.
The caller selects an approved profile, target management group, region, billing
scope, owner identities, tags, budget settings, logging destination/profile and
network pool/connectivity/subnet-layout profile. Platform-owned profile definitions
map those choices to allowed resource IDs, policies and permissions.

Do not place secrets in request files. Customer-specific real inputs remain ignored
tfvars; tracked examples are sanitized. Consumers cannot supply arbitrary policy
exemptions or privileged identities without review. Use a customer-isolated state,
repository/configuration boundary and central service references.

Delivery record should identify subscription/tenant/management group, request and
baseline version, group object IDs/roles, selected policy assignments/inheritance,
Activity Log destination, budget, and for connected profiles the VNet/CIDR/pool,
subnets, network group/hub enrollment and route/DNS validation. Include readiness
status, pending asynchronous evaluations and approved exemptions. A receipt is not
evidence unless backed by checks and actual resource IDs.

Before marking ready, verify at least:

- Existing alias matches the request and expected tenant; placement is correct.
- Roles bind intended groups to intended scopes; membership is externally owned.
- Required inherited governance is present; required remediation completes or is
  recorded as pending with an explicit handover gate.
- Activity Log export configuration exists and a test event arrives at the selected
  destination within an agreed observation window; budget/recipients are correct.
- Connected VNet allocation is recorded, peerings/enrollment converge, effective
  routes point to the intended firewall, DNS works, and allow/deny tests match policy.
- Retry/destroy plans preserve subscription, state, shared services and allocations.

## Existing lab and implementation sequence

The user created the Identity subscription and completed its association to
mg-identity. Preserve its existing creation state and alias. Later baseline work
must target that returned UUID; it must not create another Identity subscription
or re-own placement in another state. The other four platform subscriptions remain
pending after timeouts; confirm current Azure/billing status before further creation.
The current full vending plan therefore still includes those outstanding resources.

Keep runner work on hold. Do not apply the unreviewed reference topology while
revising the target design. This document does not provision any resources.

Implementation order after this design review:

1. Assess the current Azure Verified ALZ subscription vending pattern against this
   contract before adding custom baseline code. Keep existing state ownership until
   an explicit migration plan exists; do not swap implementations in place.
2. Build centrally owned logging and governance prerequisites, then AVNM/IPAM and
   regional hub/firewall/DNS. Validate provider/API support against pinned versions;
   select/version any additional provider explicitly rather than silently relying
   on an unsupported IPAM argument.
3. Build and mock-test the common subscription baseline, reusing scope-access.
4. Add the connected IPAM/spoke/enrollment/routing stage with one owner per object.
5. Test incrementally using Identity where appropriate, with explicit plans,
   propagation/billing checks, evidence and recovery. Add CI/CD only when resumed.

## Sources

- [Microsoft subscription vending guidance](https://learn.microsoft.com/en-us/azure/architecture/landing-zones/subscription-vending)
- [Vending product lines](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/subscription-vending-product-lines)
- [AVNM IPAM](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-ip-address-management)
- [AVNM connectivity ownership](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-connectivity-configuration)
- [Policy remediation identities and permissions](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources)
- [Activity Log and resource log distinction](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/activity-log)
- [Budget behavior](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [Current AVM Terraform vending pattern documentation](https://azure.github.io/Azure-Landing-Zones/sub-vending/tf/)
