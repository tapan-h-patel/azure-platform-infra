# Azure Landing Zones adoption decisions

## Purpose and process

Assess the Microsoft Azure Landing Zones (ALZ) Terraform accelerator and Azure
Verified Modules (AVMs) as the foundation of this reusable customer accelerator.
Ask the user one question at a time. Record each answer here before moving to
the next decision. Recommendations and unanswered questions are not approvals.
Keep implementation changes separate from this discovery process.

## Confirmed requirements carried forward

- The lab is the first consumer; support other customer tenants and environments.
- Use Terraform, reusable modules and variable-driven deployment roots, with
  deployment values in terraform.tfvars and sanitized examples in source control.
- Keep documentation current alongside implementation changes.
- Work on a separate branch; local review precedes authorized commits, pushes
  and pull requests.
- Keep AKS manifests in aks-git-ops and application source in app1.
- Target private connectivity and hub/spoke networking with Azure Firewall.
- Subscription vending should cover access, governance, logging and networking,
  with centrally governed IP allocation; exact implementation remains to assess.
- GitHub Actions and private self-hosted runners are part of the initial setup
  (decision 006 supersedes the earlier runner hold). The repository is currently
  public and the GitHub account is personal.

## Existing deployment constraints

Management groups, scoped security groups and an Identity subscription have
already been deployed. Preserve their current Terraform ownership until a
reviewed transition is agreed. Do not recreate resources or change state as a
side effect of evaluating the official accelerator. Existing subscription
creation eligibility issues are independent of the module choice.

## Decision log

### 001 - Adoption approach

Status: confirmed by user on 2026-11-14.

Decision: use the official ALZ Terraform accelerator as the starting point.
Adapt its generated structure and deployment approach to the confirmed customer
requirements. Retaining the current custom structure is not the selected approach.

Question: Should the official ALZ Terraform accelerator become the starting
point for the platform, or should the current repository structure remain the
starting point with selected AVMs replacing custom implementations?

- Recommended: accelerator-first; adapt its generated structure and deployment
  approach, retaining customer configuration and necessary extensions.
- Alternative: retain the current structure and integrate selected AVMs;
  maintain more deployment composition ourselves.

Neither option authorizes deployment or changes to existing Terraform state.

### 002 - Existing lab deployments

Status: confirmed by user on 2026-11-14.

Decision: plan a clean foundation rebuild, reviewing what must be retained.
This supersedes the recommendation to adopt the existing foundation in place.
Inventory existing resources and Terraform state before proposing removal;
subscription retention and state storage retention remain undecided.
Subscription retention was subsequently resolved by decision 004: retain existing
subscriptions. Decision 005 retains state storage subject to compatibility review.

Question: Should we preserve the existing lab resources and plan their adoption
into the accelerator, or plan a clean rebuild of the lab foundation?

- Recommended: preserve existing resources and prepare an explicit adoption and
  state ownership plan, including the Identity subscription and remote state.
- Alternative: plan a clean foundation rebuild, identifying exactly what can be
  recreated and what must be retained before any destructive action.

An answer selects the planning approach only. It does not authorize deletion,
subscription cancellation, deployment or Terraform state modifications.

### 003 - Management group hierarchy starting point

Status: confirmed by user on 2026-11-14.

Decision: retain the previous custom management group hierarchy:

```text
Tenant Root (existing)
└── Root
    ├── Platform
    │   ├── Connectivity
    │   ├── Identity
    │   ├── Management
    │   ├── Observability
    │   └── Security
    └── Workloads
        ├── Dev
        ├── UAT
        └── Prod
```

Use this as the accelerator customization target. Assess module support and
explicitly map policy assignments and inheritance to this hierarchy; do not
silently substitute the default hierarchy. Exact naming remains configurable.

Question: Should we assess the accelerator's standard management group hierarchy
as the starting point, or retain the previously designed custom hierarchy?

- Assess the standard accelerator hierarchy first; explain each scope and its
  policy/access implications before agreeing any customizations.
- Retain the custom hierarchy: root; platform with connectivity, identity,
  management, observability and security; workloads with dev, uat and prod.

This selects the design starting point, not approval of an unseen hierarchy or
its default policy assignments. Final hierarchy and policies require review.

### 004 - Existing subscriptions during the rebuild

Status: confirmed by user on 2026-11-14.

Decision: retain and reuse existing subscriptions; create additional ones where
needed. Place retained subscriptions under the agreed rebuilt hierarchy through
a reviewed transition. Preserve the existing Identity subscription and its alias
ownership; do not cancel or replace it as part of the foundation rebuild.
Additional subscription creation remains subject to billing eligibility.

Question: Should the clean foundation rebuild retain existing subscriptions,
including the successfully created Identity subscription, and place them under
the rebuilt hierarchy?

- Retain and reuse existing subscriptions; create additional subscriptions only
  where needed and permitted by the billing agreement.
- Plan replacement subscriptions instead; assess billing eligibility and
  retention requirements before proposing any cancellation.

This decision is separate from recreating management groups or security groups.
No subscription cancellation or state operation is authorized by this question.

### 005 - Terraform state storage during the rebuild

Status: confirmed by user on 2026-11-14.

Decision: keep the existing Terraform state storage account, subject to
compatibility review with the selected accelerator configuration. Review backend
keys, access and private connectivity before implementation. Preserve existing
state and ownership throughout the transition.

Question: Should we retain the existing Terraform state storage account or plan
new accelerator state storage?

- Retain the account, subject to compatibility review; decide state keys, access
  and private connectivity separately. This does not mean reusing old state keys
  for unrelated configurations.
- Plan new storage, retaining old storage and state until a reviewed transition
  and any required migration are complete.

Neither option authorizes overwriting state, changing backend configuration,
deleting old storage or deploying new resources.

### 006 - Initial deployment workflow

Status: confirmed by user on 2026-11-14.

Decision: include GitHub Actions and private self-hosted runners from the start.
This supersedes the earlier hold on runner implementation. Design federated
authentication, private connectivity and PR trust boundaries before deployment.
Keep local review before authorized commits, pushes and pull requests.

Question: Should the initial accelerator setup support local review and manual
Terraform execution first, with CI/CD later, or include GitHub Actions and private
self-hosted runners in the initial implementation?

- Local first: retain the existing hold on runner implementation; prepare and
  review configuration locally before planning a separate automation stage.
- CI/CD initially: revisit the runner hold and design private runner access,
  federated identity and trusted PR execution for the public repository before
  provisioning automation.

The target PR-plan/main-apply workflow remains a requirement in either case.
This question selects sequencing; it does not authorize an Azure deployment or
GitHub changes.

### 007 - Repository visibility for private runner use

Status: confirmed by user on 2026-11-14.

Decision: plan to make the deployment repository private. Visibility has not
been changed. Review repository protection and runner trust controls during the
CI/CD design; private visibility alone is not the complete access boundary.

Question: Should azure-platform-infra become private for the initial deployment,
or remain public with an explicitly restricted runner workflow?

- Plan private visibility for the deployment repository; sharing a sanitized
  accelerator template can be assessed separately later.
- Keep it public; design a trust boundary so untrusted PR code cannot execute
  on Azure-connected runners. Public PR validation must be isolated from private
  deployment execution.

Private visibility alone does not make all PR code trusted. Review workflow
permissions, author trust and runner isolation in either case. This is a design
decision only, not authorization to change repository visibility immediately.

### 008 - GitHub ownership for the initial deployment

Status: confirmed by user on 2026-11-14.

Decision: keep the existing personal GitHub account for the initial deployment.
Do not plan an organization transfer. Accelerator bootstrap compatibility and
private repository feature availability still require assessment.

Question: Should the initial deployment stay under the existing personal GitHub
account, or should we plan an organization-owned repository?

- Keep the personal account; assess accelerator bootstrap compatibility and the
  account plan's private repository controls before choosing the workflow.
- Plan organization ownership; assess the required GitHub plan, permissions and
  repository transfer or creation steps before implementation.

No account upgrade, repository transfer or organization creation is authorized.
Do not assume all accelerator bootstrap paths or GitHub protection features are
available for either option without checking their current requirements.

### 009 - Personal GitHub plan

Status: confirmed by user on 2026-11-14.

Answer: GitHub Free. No upgrade has been agreed. The selected private personal
repository cannot enforce the required PR protection on this plan; resolve this
constraint before finalizing the CI/CD design.

Question: Is the personal account on GitHub Free or GitHub Pro?

Verified against GitHub documentation on 2026-11-14:

- Protected branches for private personal repositories require GitHub Pro.
- Private repository environments are available on Pro; environment required
  reviewers are only available for public repositories on Free/Pro/Team.
- PR approval and an environment deployment approval are separate controls.

Do not assume that making this repository private preserves its existing main
branch protection on Free. No plan upgrade is authorized by this assessment.

Sources:
- [Protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Deployment environments](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)

### 010 - Resolve private repository protection constraint

Status: confirmed by user on 2026-11-14.

Decision: stay on GitHub Free with a private personal repository and accept a
manual PR process without enforced branch protection. No upgrade is planned.
This is an explicit lab limitation: the process relies on the operator following
the agreed review/merge steps. Do not represent it as enforced PR protection or
carry it into customer deployments without reviewing their control requirements.
Private visibility remains planned, not yet changed.

Question: Which planning trade-off should resolve the conflict between GitHub
Free, private personal repository visibility and enforced PR protection?

- Plan a GitHub Pro upgrade: retain private visibility and personal ownership,
  with private repository branch protection. No purchase is authorized.
- Stay on Free and keep the repository public: revisit decision 007 and require
  isolation of untrusted PR validation from Azure-connected runners.
- Stay on Free and private: explicitly accept a procedural PR/merge process
  without GitHub-enforced branch protection. Record this as a lab limitation,
  not a production customer template control.

Do not silently weaken the required PR controls or change visibility/plan. GitHub
Pro does not add environment required-reviewer gates to private repositories;
the planned approval point remains the PR/merge process, subject to later review.

### 011 - Apply trigger with a procedural PR process

Status: confirmed by user on 2026-11-14.

Decision: keep automatic Terraform apply when main changes. Retain the original
PR-plan/main-apply goal. The user explicitly accepts that a direct push to main
could also trigger deployment because branch protection is not enforced under
the selected Free/private personal repository arrangement. Follow the manual
review/PR/merge process; do not add a mandatory manual apply trigger.

Question: Given the accepted absence of enforced branch protection, should apply
still run automatically on updates to main as originally requested, or should
it require a manually started workflow targeting main?

- Automatic main apply: retain the original target behavior. An unreviewed direct
  push to main could also trigger deployment; the manual PR process is the
  operator's control against this.
- Manual apply: plan after PR changes and manually start the main apply workflow
  after reviewing and merging. A manual trigger is not an enforced independent
  approval and must still be restricted to the intended ref and permissions.

This asks whether to revise the original automatic-apply requirement in light of
decision 010. No workflow execution or deployment is authorized by this decision.

### 012 - Initial regional deployment scope

Status: confirmed by user on 2026-11-14.

Decision: include a second region from the start. UK South remains primary;
the second region and the services deployed there remain to be selected. Do not
interpret this decision as duplicating every resource or implementing application
disaster recovery automatically.

Question: Should the initial platform deploy regional services only in UK South
(the previously selected region), or include a second region from the start?

- Single region: UK South initially; keep the accelerator configurable for later
  regional expansion without claiming regional disaster recovery is implemented.
- Multiple regions initially: choose the second region and agree which services
  are duplicated in subsequent questions. A second region alone is not a complete
  disaster recovery design.

This selects initial deployment scope. Do not change the already selected UK
South primary region or infer a second region without the user's answer.

### 013 - Second Azure region

Status: confirmed by user on 2026-11-14.

Decision: use UK West (ukwest) as the second region alongside primary UK South
(uksouth). Required service/SKU availability and subscription access remain to
be validated before deployment.

Question: Which Azure region should accompany UK South?

Record the selected region explicitly. Validate required service/SKU availability
and subscription access during implementation. Do not infer regional replication,
failover behavior or disaster recovery objectives from the region choice alone.

### 014 - Initial regional hub and firewall footprint

Status: confirmed by user on 2026-11-14.

Decision: deploy the UK South hub VNet and Azure Firewall first; defer the UK
West hub and firewall. This refines decision 012: two regions are selected for
the design, but both regional network stacks are not initially deployed. The
remaining initial UK West footprint is pending decision 015. Do not create UK
West spokes with an assumed transit path before routing is explicitly agreed.

Question: Should each selected region have its own hub VNet and Azure Firewall
from the start, or should UK West hub/firewall deployment be staged for later?

- Deploy a hub VNet and Azure Firewall in both UK South and UK West initially;
  this duplicates the regional firewall footprint and associated running costs.
- Deploy the hub/firewall in UK South initially; include UK West in the design
  but explicitly defer its hub/firewall deployment. This narrows the initial
  two-region implementation and requires agreement on any interim connectivity.

This decision does not select firewall SKU, inter-region routing, workload
replication or failover. Address those separately; do not infer automatic DR.

### 015 - Initial UK West footprint

Status: confirmed by user on 2026-11-14.

Decision: UK West is configuration only for future expansion; initial regional
resources deploy in UK South. This resolves the initial scope of decisions
012-014: the design names two regions, but initial deployment is single-region.
Do not claim deployed regional redundancy or disaster recovery.

Question: With UK West hub/firewall deferred, should UK West initially be a
configured future deployment region with no regional resources, or should it
host selected services from the start?

- Configuration only: retain UK West as an expansion target; initial regional
  resources deploy in UK South. Do not describe this as deployed multi-region DR.
- Selected UK West services: identify those services and their private access,
  routing and availability requirements in subsequent questions before design.

Region selection does not itself create resources or enable replication.

### 016 - Platform subscription boundaries

Status: confirmed by user on 2026-11-14.

Decision: retain one subscription per Platform area, five total: Connectivity,
Identity, Management, Observability and Security. Reuse suitable existing
subscriptions as agreed in decision 004. Any outstanding subscription creation
must respect billing eligibility; do not consolidate boundaries implicitly.

Question: Should the accelerator retain the previously requested separate
subscription for each Platform area: Connectivity, Identity, Management,
Observability and Security?

- Retain five separate subscription boundaries, with the existing Identity
  subscription reused and other existing suitable subscriptions reviewed before
  requesting additional ones. Billing eligibility can stage creation; it does
  not silently change the target architecture.
- Consolidate some platform areas into fewer subscriptions; agree which areas
  share a subscription in the next question before changing the design.

Management group hierarchy remains as confirmed in decision 003. This question
concerns subscription boundaries, not deletion or new subscription creation.

### 017 - Workload subscription boundaries

Status: confirmed by user on 2026-11-14.

Decision: use a separate subscription per application and environment under
the corresponding Dev, UAT and Prod management groups. Examples app1-dev,
app1-uat and app1-prod describe boundaries, not final Azure subscription names.
Keep naming configurable and reuse suitable existing subscriptions where agreed.

Question: Under the Dev, UAT and Prod management groups, should subscriptions be
shared by applications per environment, or dedicated per application/environment?

- Per application/environment: for example, app1-dev, app1-uat and app1-prod;
  future applications can receive their own subscriptions under the same
  environment management groups.
- Shared per environment: one Dev, one UAT and one Prod subscription initially,
  with applications sharing their environment subscription.

This selects the initial workload vending boundary. It does not move AKS YAML
or application source into this repository or authorize subscription creation.

### 018 - Initial rollout scope

Status: confirmed by user on 2026-11-14.

Decision: establish the platform foundation and CI/CD first; workload subscription
vending follows in the next phase. Do not include app1 subscription creation or
application infrastructure in the first rollout merely because it is described
in the target design.

Question: Should the first rollout establish the platform foundation and CI/CD
before workload subscription vending, or include app1 workload vending in the
initial rollout after its platform dependencies are ready?

- Platform first: establish the agreed hierarchy, platform subscription layout,
  baseline services and CI/CD; introduce application subscription vending in
  the following phase. The full vending design remains a target requirement.
- Platform plus app1 vending: include app1 landing zone vending in the initial
  rollout, sequenced after the platform dependencies. Agree the first app1
  environment separately; do not assume all environments are deployed at once.

Neither option includes application deployment or changes ownership of AKS
manifests and application source. No deployment is authorized by this question.

### 019 - Operator access to private resources

Status: confirmed by user on 2026-11-14.

Decision: CI/CD runners only for routine private resource access; no routine
private access from the laptop. Local work remains code review and offline
checks. Do not add a standing workstation VPN or management VM by default.
Bootstrap and recovery must not depend solely on the runner being recovered.

Question: For the initial platform, how should the operator access private Azure
resources such as Terraform state from the local WSL workstation?

- Point-to-site VPN: plan private workstation connectivity and DNS resolution;
  assess gateway, authentication, WSL reachability and cost before implementation.
- Azure management workstation: plan a private Azure host and an access method
  such as Bastion, with required tools and DNS; assess its cost and bootstrap.
- Pipeline-only private resource access: keep Azure-connected operations on the
  private runners after bootstrap; local work is code review and offline checks.
  Document how runner/bootstrap recovery can be performed if CI is unavailable.

No existing VPN or on-premises connectivity is assumed. Plan staged bootstrap
before removing current storage access. Do not treat control-plane CLI login as
providing network access to private endpoints.

### 020 - Emergency private access when runners are unavailable

Status: confirmed by user on 2026-11-14.

Decision: use a temporary Azure management host for emergency recovery, not a
routine workstation VPN. Its provisioning, operator access method, credentials,
private DNS, state access and cleanup remain to be designed. Recovery must be
possible without relying on the failed runner.

Question: Should the recovery design use an on-demand Azure management host
with private access, or an on-demand workstation VPN?

- Temporary management host: prepare a recovery procedure to provision and
  access a host without the failed runner; define narrowly scoped access,
  private DNS, required tools and cleanup. Choose the access mechanism later.
- Temporary VPN: prepare a recovery procedure for workstation private access;
  validate authentication, DNS, WSL reachability and removal after recovery.

Neither option is routine access or authorizes provisioning. The bootstrap and
recovery procedure must identify its independent credentials, permissions and
state access path before it is considered usable. Do not assume that merely
creating a VM inside the VNet provides an operator access path.

### 021 - Human privileged access model

Status: confirmed by user on 2026-11-14.

Decision: use standing group-based role assignments initially. Retain the
previously requested scope-specific Reader, Contributor and Owner groups.
Do not include PIM implementation in the initial lab scope. Human group
membership management remains separate from pipeline identities.

Question: For the initial lab, should the previously requested Reader,
Contributor and Owner groups use standing Azure role assignments, or should
we assess time-limited privileged access through Microsoft Entra PIM?

- Standing assignments initially: retain the scoped group model; membership
  grants the group's assigned access without a separate activation step.
- Assess PIM before implementation: determine tenant licensing and supported
  group/role activation options before selecting a design. Do not assume PIM
  entitlement exists or silently purchase licenses.

Keep scope-specific group names as previously requested. This concerns human
access; pipeline identities and their permissions require a separate design.

### 022 - Plan and apply identity separation

Status: confirmed by user on 2026-11-14.

Decision: separate Azure identities for PR plan and main apply. Minimize plan
permissions and scope apply permissions to deployment responsibilities. Review
state access, Entra permissions, federation trust and workflow permissions before
assigning roles; separate identities alone do not enforce this boundary.

Question: Should PR plan and main apply use separate Azure identities or share
one identity for the initial lab?

- Separate identities: aim for read-oriented Azure resource permissions for
  plan and scoped deployment permissions for apply. Derive exact rights from
  the selected modules, including Entra group operations and state locking;
  do not assume Azure Reader alone is sufficient to run a plan.
- Shared identity: accept that PR plan execution can access the same Azure
  permissions as apply. Record this as an explicit lab simplification.

Use federated workload authentication as the existing target; avoid stored
client secrets. Identity separation is not effective unless federation and
workflow permissions prevent PR jobs from obtaining the apply identity. Assess
the accelerator's generated authentication model before implementing extensions.

### 023 - Initial Azure Policy enforcement approach

Status: confirmed by user on 2026-11-14.

Decision: observe compliance first, then review tighter enforcement later.
Select supported audit/non-enforcing settings individually after reviewing the
actual assignments. Document which controls are not enforced and the follow-up
enforcement review; do not describe policy observation as preventive enforcement.
This does not relax explicitly configured resource security requirements such
as the agreed private connectivity design.

Question: Should we review the selected ALZ policy assignments and enforce
agreed controls from the first rollout, or first observe compliance with
supported audit/non-enforcing settings and tighten enforcement later?

- Enforce agreed controls initially: inspect assignment parameters, effects,
  scope, exemptions, identities and remediation behavior before deployment.
- Observe first: choose supported audit or non-enforcing settings per policy;
  document controls not enforced and agree a later enforcement review.

Neither option approves every accelerator default policy or an automatic effect
conversion. Do not assume all definitions support Audit, or that policy effects
and assignment enforcement modes are interchangeable. Existing resources and
bootstrap dependencies require review under either approach.

### 024 - Initial security monitoring scope

Status: confirmed by user on 2026-11-14.

Decision: use Azure Monitor and Log Analytics initially; defer Microsoft
Sentinel to a later phase. Keep the Security subscription boundary, but do not
enable Sentinel or its connectors as an accelerator default in the first rollout.

Question: Should the initial rollout establish Azure Monitor and Log Analytics
without Microsoft Sentinel, or include a Sentinel assessment and deployment?

- Azure Monitor and Log Analytics first: defer Sentinel; define central logging
  ownership, workspace placement, retention and diagnostics separately.
- Include Sentinel: assess workspace placement, data sources, permissions and
  current pricing before enabling it. Do not infer that every log source or
  connector should be enabled.

The Security subscription remains part of the agreed layout either way. This
decision does not select paid Defender plans or approve monitoring expenditure.

### 025 - Central Log Analytics workspace placement

Status: confirmed by user on 2026-11-14.

Decision: place the initial central platform Log Analytics workspace in the
Observability subscription. Assess the accelerator's support for this placement
and the required cross-subscription access. Do not silently use Management
instead. Workspace retention, private access and log collection remain to review.

Question: Should the initial central platform Log Analytics workspace be placed
in the dedicated Observability subscription or in Management?

- Observability: use the custom hierarchy's dedicated monitoring boundary.
  Assess accelerator customization and cross-subscription permissions.
- Management: place the central workspace alongside platform management
  services; retain Observability for future responsibilities unless revised.

This selects placement for the initial central platform workspace, not a rule
that every future workload or security log must share it. Workspace count,
retention, private access and future Sentinel placement require separate review.

### 026 - Paid Defender for Cloud plans

Status: confirmed by user on 2026-11-14.

Decision: defer paid Defender for Cloud plans initially. Review accelerator
defaults and policy assignments to avoid enabling paid tiers or trials. Review
existing subscription settings separately; this decision does not authorize
silently disabling existing protections.

Question: Should the initial rollout avoid enabling paid Defender for Cloud
plans, or assess selected paid plans for inclusion?

- Defer paid plans: do not enable paid Defender tiers or trial opt-ins through
  accelerator defaults or policy assignments. Review existing settings before
  proposing changes; do not silently disable protections already enabled.
- Assess selected paid plans: review workload applicability, current pricing,
  licensing and assignment scope before proposing which plans to enable.

Sentinel deferral does not decide Defender scope. Neither option is a blanket
approval to enable or disable subscription security settings.

### 027 - Initial directory service scope

Status: confirmed by user on 2026-11-14.

Decision: Microsoft Entra ID only initially. Do not deploy AD domain controllers
or managed domain services. Retain the Identity subscription as the agreed
boundary for future identity infrastructure. Entra security groups and federated
pipeline identities remain in scope and are tenant objects, not resources hosted
inside that subscription.

Question: Should the initial lab use Microsoft Entra ID without deploying
directory servers or managed domain services, or does it require an AD domain?

- Entra ID only initially: retain the Identity subscription for future services;
  do not deploy domain controllers or Microsoft Entra Domain Services by default.
  Entra tenant groups and pipeline identities are still part of the access design.
- AD domain required: clarify self-managed AD DS versus managed domain services,
  integration and application requirements before selecting infrastructure.

Entra tenant objects do not reside inside the Identity Azure subscription.
This decision concerns additional directory infrastructure, not whether Entra
authentication or scope-specific security groups are used.

### 028 - Private address allocation prerequisites

Status: confirmed by user on 2026-11-14.

Decision: propose a new lab address plan for user review. No existing ranges
were supplied; that does not establish that overlaps are absent. Sample CIDRs
in existing Terraform are not approval of the proposed plan.

Question: Is there an existing private address plan or any home, VPN, corporate,
WSL or other Azure network ranges we must avoid, or should we propose a new lab
address plan for review?

- Existing constraints: collect the ranges and intended future connectivity
  before selecting the root IPAM pool or assigning hub/spoke address space.
- New plan: propose configurable root and regional allocations for review;
  validate known overlaps before deployment. Do not assume sample CIDRs in the
  unreviewed custom hub/spoke root are approved.

Central IPAM remains the target. The authoritative pool boundaries and allocation
sizes are not selected by this question. Keep customer-specific ranges in tfvars.

### 029 - Proposed lab address plan

Status: confirmed by user on 2026-11-14 as the design baseline.

Decision: accept the proposed address plan below. Keep ranges configurable and
validate overlaps and service sizing before deployment. This is design approval,
not authorization to provision networks or IPAM resources.

| Purpose | Proposed CIDR | Treatment |
| --- | --- | --- |
| Lab root pool | 10.64.0.0/12 | IPAM allocation boundary; never assign the entire pool to one VNet |
| UK South regional pool | 10.64.0.0/14 | Initial region |
| UK West regional pool | 10.68.0.0/14 | Reservation only, consistent with decision 015 |
| Future expansion | 10.72.0.0/13 | Reserved |
| UK South hub VNet | 10.64.0.0/22 | Carved from UK South pool |
| UK South workload spoke allocation pool | 10.65.0.0/16 | Proposed /20 per application/environment spoke |

The remaining UK South space is reserved for platform spokes and growth.
Subnet layouts, private endpoint placement, runner network requirements, AKS
pod/service ranges and IPAM provider capabilities must be reviewed separately.
A /20 is a proposed default, not an immutable limit for every customer/workload.
Central IPAM must own actual spoke allocations; illustrative addresses must not
compete with it. Region pools reserve address space without creating VNets.

Question: Approve this address plan as the design baseline, or revise it?

Approval establishes the design baseline only. Check existing Azure, local/WSL,
VPN and future connected network ranges for overlaps before deployment. Keep
ranges configurable and do not deploy UK West resources from this reservation.

### 030 - Initial external private network connectivity

Status: confirmed by user on 2026-11-14.

Decision: external private network connectivity is required initially. The
remote network, connection type, device/provider capabilities, remote address
ranges and routing remain undecided. Do not assume a site-to-site VPN or
ExpressRoute circuit exists or deploy a gateway before those requirements are
established. Validate the accepted lab address plan against the remote ranges.

Clarification on 2026-11-14: the user subsequently specified "On-prem networks"
for IP space reservation (decision 032). Treat this as address planning only;
a live external connection or gateway is not an initial deployment requirement
without a further explicit decision. This supersedes the earlier interpretation.

Question: Does the initial platform require a site-to-site VPN or ExpressRoute
connection to a home, office, datacenter or other external private network, or
should it be Azure-only initially?

- Azure-only initially: do not deploy site-to-site VPN or ExpressRoute gateways
  by default. Keep future external connectivity configurable. This does not
  prohibit required outbound internet connectivity for GitHub and dependencies.
- External private connectivity required: collect the connection type, remote
  network ranges, endpoint ownership and routing requirements before design.

This concerns network-to-network connectivity, separate from routine operator
access through runners and the temporary recovery host already agreed.

### 031 - External network destination

Status: confirmed by user on 2026-11-14.

Decision: connect to another cloud or hosted network. Provider, network identity,
address ranges and connection capabilities remain to be identified. Do not assume
the destination is a home/office network or that a gateway already exists.

Superseded by decision 032: use the generic label On-prem networks for reserved
address space; no cloud or hosting provider needs to be selected at this stage.

Question: What external network should the initial Azure hub connect to: a home
lab, an office/datacenter network, or another network?

Identify the destination before choosing VPN versus ExpressRoute. Collect remote
CIDRs and connectivity capabilities in subsequent questions. Keep remote access
details configurable; do not ask for VPN secrets or private keys in this record.

The agreed runner-only routine administration model remains unchanged unless
the user explicitly revises it. External network connectivity alone does not
authorize routine laptop access to private Azure resources.

### 032 - Remote cloud or hosting provider

Status: resolved by user clarification on 2026-11-14.

Decision: "Just call it On-prem networks for ip space reservation."
Use On-prem networks as the generic address reservation label. Do not infer a
provider, existing remote network or initial VPN/ExpressRoute deployment. The
reserved CIDR remains undecided. Keep it disjoint from the Azure root pool
10.64.0.0/12 and configurable for customer-specific address plans.

Question: Which cloud or hosting provider hosts the remote network?

Identify the provider before assessing supported VPN/interconnect options. A
provider answer does not establish that the remote network exists, that the user
can manage it, or that address ranges do not overlap; clarify those separately.

### 033 - On-prem networks address reservation

Status: confirmed by user on 2026-11-14 after CIDR clarification.

Final decision: reserve 192.168.0.0/16 under On-prem networks. This supersedes
the supplied /12 and the rejected 10.0.0.0/10 proposal below. Treat this as an
address-planning reservation only, not a live connection or gateway deployment.
The range does not overlap the Azure allocation pool 10.64.0.0/12.

Decision: use a different CIDR reservation. Do not reserve 10.0.0.0/10. The
replacement range has not been provided; keep the On-prem networks reservation
unset and ask for the intended CIDR or CIDRs before implementing it.

User subsequently supplied 192.168.0.0/12. This is not a canonical /12 network:
its containing network is 192.160.0.0/12, spanning 192.160.0.0-192.175.255.255
and including public address space. Do not normalize and accept it silently.
The RFC 1918 private block starting at 192.168.0.0 is 192.168.0.0/16, covering
192.168.0.0-192.168.255.255. Ask whether /16 was intended before selecting the
reservation. Neither supplied /12 nor proposed /16 is approved for implementation.
The subsequent user confirmation above approves /16 as the design reservation.

Proposal: reserve 10.0.0.0/10 (10.0.0.0 through 10.63.255.255) under the label
On-prem networks. This does not overlap the agreed Azure root pool 10.64.0.0/12.

Question: Accept this reservation, or provide a different CIDR?

This is a planning exclusion for Azure allocations, not a claim about real
on-premises addressing. Record it in the address plan; assess how the selected
IPAM implementation represents reservations before implementation. Do not deploy
VNets, gateways, routes or connectivity from this reservation alone.

### 034 - Azure Firewall tier

Status: confirmed by user on 2026-11-14 following Basic assessment.

Decision: continue with Azure Firewall Basic for the initial UK South hub;
assess private DNS separately. Do not configure firewall DNS proxy or network-rule
FQDN features unsupported by Basic. Exact costs, regional availability and
pinned accelerator/module behavior remain implementation checks.

Assessment against official documentation on 2026-11-14:

- The accelerator documents changing the firewall tier to Basic; it is not
  categorically unsupported.
- Basic supports network rules, application FQDN filtering and logging, but
  lacks firewall DNS proxy, network-rule FQDN filtering and threat-intelligence
  deny mode. Its documented scale is up to 250 Mbps.
- Therefore Basic cannot be substituted while retaining a DNS design that uses
  the firewall as the spokes' DNS proxy. Private endpoint name resolution needs
  a separately validated approach, such as zone links to relevant VNets or
  appropriate DNS resolver infrastructure. Central zone ownership does not
  inherently require the firewall to provide DNS proxy.
- Exact UK South deployment costs and pinned-module behavior remain unchecked;
  do not assert a numeric price or that Basic is necessarily the cheapest total
  architecture after DNS requirements are included.

Follow-up question: choose Standard to retain firewall DNS proxy capability, or
continue with a Basic-based design and assess the separate private DNS approach?

Question: Which tier should be assessed for the initial UK South firewall:
Standard, Premium or Basic?

- Standard: proposed starting point for the platform hub with DNS proxy and
  network/application filtering, without Premium TLS inspection and IDPS.
- Premium: assess if TLS inspection or IDPS learning is an initial requirement;
  selecting the tier does not automatically configure those capabilities.
- Basic: assess reduced features and accelerator compatibility before selection.

Validate current pricing, regional availability and selected accelerator support
before implementation. No firewall deployment or spend is authorized here.

Reference reviewed on 2026-11-14:
[Firewall feature comparison](https://learn.microsoft.com/en-us/azure/firewall/features-by-sku).

[Accelerator firewall SKU customization](https://azure.github.io/Azure-Landing-Zones/accelerator/starter-terraform/options/firewall-sku/).

### 035 - Private DNS zone ownership

Status: confirmed by user on 2026-11-14.

Decision: centrally manage private DNS zones in the Connectivity subscription.
Do not deploy duplicate subscription-owned zones by default. Resolution and
cross-subscription integration remain to be designed independently of Basic.

Question: Should the platform centrally own private endpoint DNS zones in the
Connectivity subscription, or should each subscription own its own zones?

- Central ownership: assess links to the VNets needing resolution and explicit
  permissions for private endpoint DNS integration. Do not use Firewall Basic
  as a DNS proxy; validate the resolution path and accelerator customization.
- Per-subscription ownership: each subscription manages its zones; assess
  cross-subscription service discovery and avoid inconsistent duplicate records.

Ownership is distinct from the resolution mechanism. Central zones do not imply
that a DNS resolver service must be deployed. Decide resolver infrastructure
only after assessing client networks and name resolution requirements.

### 036 - Initial private DNS resolution mechanism

Status: confirmed by user on 2026-11-14.

Decision: use central private DNS zone links with Azure-provided DNS initially.
Do not deploy DNS Private Resolver by default. Link relevant zones to each VNet
containing clients that need resolution; validate cross-subscription permissions,
private endpoint integration and service-specific DNS behavior before deployment.

Proposal: use Azure-provided DNS with central private DNS zone links to each
VNet containing clients that need those zones, including runner/recovery VNets
as applicable. Do not deploy a dedicated DNS Private Resolver initially.

Rationale: current scope has Azure clients, no AD/custom DNS and only an on-prem
address reservation. Microsoft documents linking shared zones to the hub/spokes
that need resolution, including across subscriptions. Firewall Basic is not used
as DNS proxy. Validate service-specific behavior and accelerator customization.

Alternative: assess deploying DNS Private Resolver now for an explicitly defined
DNS requirement or learning goal; select endpoints/rules and cost separately.

Question: accept direct VNet zone links initially, or assess Private Resolver now?

Reference checked on 2026-11-14:
[Private Endpoint DNS integration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration).

### 037 - Default spoke-to-spoke access policy

Status: confirmed by user on 2026-11-14.

Decision: deny spoke-to-spoke access by default; explicitly allow required flows
through the hub firewall. Do not add broad inter-spoke or inter-environment
allow rules for convenience. Inventory CI/CD, shared service and private endpoint
flows and validate actual routing before declaring enforcement complete.

Question: Should spoke-to-spoke access default to denied, with explicit approved
flows through the hub firewall, or should selected broad spoke access be allowed
through the firewall initially for lab convenience?

- Default deny: define specific source/destination/port requirements before
  permitting flows. Shared services and CI/CD access need explicit allowances.
- Broader lab access: agree the exact boundaries and protocol scope separately;
  do not infer unrestricted production or inter-environment access.

Both options retain the agreed hub transit model, with no direct spoke peering
or mesh bypass. Routing, private endpoint paths and subnet policies must be
verified separately; a firewall access policy alone does not force traffic
through the firewall. DNS zone visibility does not itself grant network access.

### 038 - Initial outbound internet access policy

Status: confirmed by user on 2026-11-14.

Decision: allow broad outbound HTTPS initially, then tighten it after reviewing
observed dependencies. Record this as a temporary lab exception, not a customer
production default. Define source subnets explicitly and retain hub firewall
egress routing where supported. Do not infer permission for arbitrary outbound
protocols, inbound internet access or broader spoke-to-spoke traffic.

Question: Should outbound internet access be restricted to documented required
destinations from the start, or allow broad outbound HTTPS initially and tighten
it after observing the lab?

- Destination allowlist: inventory GitHub Actions, identity, Azure management,
  Terraform provider/module sources, container images and update dependencies;
  validate against current official endpoint requirements during implementation.
- Broad HTTPS initially: define the permitted source subnets and protocols;
  record this as a temporary lab exception and review logs before tightening.

Keep outbound routing through the hub firewall where supported and explicitly
validate service-specific platform requirements. Firewall Basic supports
application FQDN rules but not FQDNs in network rules; do not assume those are
interchangeable or silently bypass required egress controls.

### 039 - CI/CD configuration input source

Status: confirmed by user on 2026-11-14.

Decision: version reviewed non-secret deployment tfvars in the private deployment
repository. This deliberately revises the blanket tfvars exclusion for selected
files after private visibility is established and file contents are reviewed.
Keep secrets excluded and shared/public examples sanitized. Existing ignored
tfvars remain ignored until explicitly reviewed; no ignore rule changes yet.

Question: Should reviewed non-secret deployment tfvars be versioned in the
planned private deployment repository, or remain out of Git and be supplied
to the workflow from GitHub configuration?

- Version non-secret tfvars: deliberately revise the existing blanket tfvars
  ignore policy for specifically selected deployment files. Keep secrets out
  of Git and keep public/shared template examples sanitized. Enable PR review
  of deployment input changes alongside code.
- Keep real tfvars out of Git: define a controlled GitHub variables/secrets
  input source and generation procedure. Non-secret configuration changes there
  are not automatically reviewed through the repository's PR process.

Both choices retain variable-driven root modules and tfvars input files. Do not
change ignore rules or expose existing ignored files until their contents are
reviewed and the repository visibility transition is complete. This question
does not authorize committing or publishing any configuration.

### 040 - Private runner lifecycle

Status: confirmed by user on 2026-11-14.

Decision: use a fresh ephemeral runner for each job, disposed of afterward.
Hosting remains undecided. The official bootstrap documents private self-hosted
networking using a Container Instances subnet; verify the selected release's
actual one-job lifecycle and cleanup rather than assuming it is ephemeral.
Do not silently substitute a persistent runner or select Container Apps solely
because earlier custom reference code used it.

Question: Should the private runners be ephemeral (fresh runner for each job),
or persistent (reuse the same runner host between jobs)?

- Ephemeral: prefer a fresh job execution environment and disposal afterward;
  assess supported accelerator hosting and scaling options before selecting a
  service. Account for job startup, registration, images and recovery.
- Persistent: retain a runner host across jobs; define patching, workspace
  cleanup, credentials and contamination controls explicitly.

The earlier Container Apps environment code is unreviewed reference work, not
approval of a hosting service. Select hosting only after checking accelerator
support, private network requirements, operational needs and current costs.

### 041 - New bootstrap resource subscription

Status: confirmed by user on 2026-11-14.

Decision: place new bootstrap resources, including private runner hosting and
deployment identities, in Management. Do not add a dedicated bootstrap
subscription. Preserve existing state storage under decision 005 and explicitly
assess cross-subscription access if it remains outside Management.

Question: Should new bootstrap resources (private runner hosting and deployment
identities) live in Management, or in a dedicated bootstrap subscription?

- Management: follow the accelerator's documented default placement and the
  existing five-platform-subscription model.
- Dedicated bootstrap subscription: add a separate isolation boundary; review
  placement, billing eligibility and access before expanding subscription count.

Retain the existing state storage account as agreed in decision 005; this question
does not authorize moving or recreating it. Assess cross-subscription state access
and bootstrap compatibility explicitly if storage remains elsewhere.

Reference checked on 2026-11-14:
[Accelerator planning](https://azure.github.io/Azure-Landing-Zones/accelerator/0_planning/).

### 042 - Initial platform log retention target

Status: confirmed by user on 2026-11-14.

Decision: target 30 days of searchable retention for central platform logs.
Validate workspace/table support, defaults and pricing before implementation;
document exceptions where a table requires different treatment. No separate
archive retention requirement has been selected.

Question: What initial searchable retention target should central platform logs
have: 30, 90 or 180 days, or another duration?

Treat the answer as a design target. Validate supported workspace/table settings,
table plan, any table-specific defaults and current retention pricing before
implementation. Do not assume all logs inherit an identical setting or that
Azure's native Activity Log retention controls exported workspace copies.
Archive retention, if required, is a separate decision. Keep the value
configurable; this does not establish a universal customer compliance standard.

### 043 - Initial operational alerting scope

Status: confirmed by user on 2026-11-14.

Decision: include selected baseline operational alerts in the first rollout.
Assess the ALZ/AMBA integration and review selected rules, notification
recipients, action groups and costs before enabling them. No recipients or
complete rule set have been approved yet; do not enable all defaults blindly.

Question: Should the first rollout include an assessment and selected deployment
of Azure Monitor Baseline Alerts (AMBA), or establish log collection first and
add baseline alerting later?

- Include baseline alerts: review the supported ALZ integration, applicable
  rules, action groups, notification recipients and costs before enabling a
  selected set. Do not assume every default rule is appropriate.
- Logging first: defer AMBA deployment; document that collecting logs alone
  does not provide an operational alerting/notification service.

Sentinel remains deferred. This does not approve sending notifications or
provisioning alert rules before recipients and selected rules are agreed.

### 044 - Overall monthly lab cost target

Status: confirmed by user on 2026-11-14.

Decision: target GBP 100 per month across the whole initial platform lab, not
per subscription. No spending authorization or guaranteed cost ceiling is implied.
Prioritize an explicit cost fit assessment before finalizing deployments.

Question: What approximate monthly budget and currency should guide the initial
platform lab across its subscriptions?

Use the target for a current cost estimate before deployment, including firewall,
runner hosting, networking, IPAM, monitoring, storage and selected alerts. Do not
promise that the agreed architecture fits until usage assumptions and prices are
checked. If the target and design conflict, present concrete trade-offs for review.

This is a planning target, not a spending cap or authorization to incur costs.
Azure budget alerts do not themselves stop resource consumption. Per-subscription
budget allocations and notification recipients remain separate implementation
inputs; do not duplicate the overall target as each subscription's budget.

### 045 - Lab runtime model for budget fit

Status: confirmed by user on 2026-11-14.

Decision: operate paid lab infrastructure during on-demand learning sessions;
preserve Terraform state and explicitly retained resources. Do not assume all
services support stopping or that all charges stop between sessions. Define
startup, shutdown and independent recovery paths before implementation, including
how private runners start when their firewall or hosting dependencies are down.

Question: Should we design paid lab infrastructure for on-demand learning
sessions, or require the initial platform to stay operational continuously?

- Session-based: assess supported stop/deallocate or teardown/recreate procedures
  per service, with recovery that does not depend on the runner/firewall being
  restarted. Preserve subscriptions, state and explicitly retained resources.
- Continuous: assess whether the GBP 100 target requires a smaller initial
  footprint or revised budget, and present concrete options before changing it.

Azure Firewall has fixed hourly deployment charges plus data processing costs.
The public pricing page did not expose a current UK South GBP rate in this
assessment; do not quote an unverified number. Estimate all retained resources
and residual charges. Session-based operation alone does not guarantee GBP 100.

Source checked on 2026-11-14:
[Firewall pricing](https://azure.microsoft.com/en-gb/pricing/details/azure-firewall/).

### 046 - Monthly active hours assumption

Status: confirmed by user on 2026-11-14.

Decision: assume 20 active learning-session hours per month for the initial lab
cost estimate, against the overall GBP 100 monthly target. This does not mean
20 hours per resource independently or remove charges outside active sessions.

Question: Approximately how many hours per month should the lab's paid runtime
be active for learning sessions?

Use this as a cost-estimate assumption, not a guaranteed runtime cap. Include
startup/shutdown time and distinguish firewall/network uptime from per-job runner
compute. Account for retained storage, private endpoints, images, logs and other
resources that continue charging outside sessions. Review the whole estimate
against the GBP 100 monthly target before deployment.

### 047 - Session shutdown trigger

Status: resolved by user clarification on 2026-11-14.

Decision: use a Terraform destroy pipeline after a module is tested. Create,
test and destroy infrastructure within the same day to minimize running costs.
This supersedes the stop/scheduled-shutdown alternatives below; no scheduled
shutdown fallback is selected. The precise test destruction boundary and
retained baseline remain pending decision 048. Do not interpret this as
authorization to execute destroy now, cancel subscriptions or delete state.

Question: Should session shutdown be manually triggered only, or should a
scheduled fallback also attempt shutdown if the operator forgets?

- Manual only: document an explicit session-end procedure and residual-cost
  checks; do not claim that budget alerts shut resources down.
- Manual plus scheduled fallback: choose schedule/timezone later and validate
  a controller path independent of the private runners/firewall being stopped.
  Handle active Terraform operations and state locks explicitly before stopping
  dependencies. A schedule is not a hard spending cap.

Exact per-service shutdown actions remain to assess; do not equate stop,
deallocate and destroy or assume every resource can be paused. Retained resources
and state must be protected under decision 045.

### 048 - Destroy pipeline boundary

Status: confirmed by user on 2026-11-14.

Decision: also design a separate shared-platform teardown workflow, distinct
from selected test-deployment teardown. Establish ordering, state boundaries,
retained resources and an independent execution/recovery path before enabling
it. Existing subscriptions and state storage remain retained. Do not run destroy
or infer approval to remove the CI/CD bootstrap from this design decision.

Question: Should the test destroy pipeline destroy only the selected test
deployment while preserving subscriptions, management groups/access, state
storage and the CI/CD bootstrap, or should the design also support tearing down
the shared platform baseline through a separate recovery-aware workflow?

- Test deployment only: isolate test state and ownership from retained baseline;
  identify shared dependencies and residual costs explicitly.
- Test deployment plus optional baseline teardown: design a separate sequence
  and independent execution path so destroying runners/networking does not strand
  operations or state. Review exact retained resources before implementation.

Existing subscriptions and state storage remain retained under decisions 004/005
unless explicitly revised. A generic terraform destroy must never implicitly
cancel subscriptions or erase the storage containing its state. Define state
boundaries rather than relying on routine resource targeting for test teardown.

### 049 - Hierarchy and human access during routine platform teardown

Status: confirmed by user on 2026-11-14.

Decision: retain management groups and human access configuration during routine
shared-platform teardown. Keep subscription placement stable. The initial clean
foundation rebuild remains a separate reviewed transition; do not repeat it as
part of normal lab create/test/destroy sessions.

Question: Should routine shared-platform teardown retain management groups and
their human access groups/role assignments, or also remove and recreate those?

- Retain: remove selected platform service resources while keeping the hierarchy,
  subscription placement and human access stable. Initial clean foundation rebuild
  remains a separate transition, not a recurring teardown requirement.
- Recreate hierarchy/access too: explicitly plan subscription relocation, group
  membership handling and independent administrator access before deletion.
  Do not delete or cancel retained subscriptions or assume memberships survive
  group recreation.

This question does not decide runner/bootstrap teardown mechanics. State storage
and subscriptions remain protected by earlier decisions. Exact destroy boundaries
must be reflected in root/state ownership and reviewed destroy plans.

### 050 - Bootstrap retention between lab sessions

Status: confirmed by user on 2026-11-14.

Decision: also design bootstrap teardown and independent rebuild. Do not retain
the runner bootstrap by assumption between tests. Integrate the temporary Azure
management-host recovery choice from decision 020 into the assessment, without
assuming its operator access or private state path is already implemented.
Subscriptions, state storage, hierarchy and human access remain retained.

Question: Should the private runner bootstrap infrastructure remain between
tests, with ephemeral runners created per job, or should a separate bootstrap
teardown/rebuild procedure also be designed?

- Retain minimal bootstrap: identify the runner control/hosting dependencies,
  private state access, network egress and their idle costs. Do not assume the
  full platform firewall can be destroyed while a dependent runner still works.
- Rebuild bootstrap too: define an independently executable bootstrap/recovery
  procedure outside the runners being removed, including access to retained
  private state. Select that execution method separately before implementation.

Both options retain subscriptions, state storage, hierarchy and human access.
Ephemeral job runners do not imply all supporting network/hosting infrastructure
has zero idle cost. Resolve dependency cycles and estimate retained costs before
claiming compliance with the GBP 100 monthly target.

### 051 - Destroy workflow initiation

Status: confirmed by user on 2026-11-14.

Decision: automatically clean up disposable module-test deployments when tests
finish; manually initiate shared-platform and bootstrap teardown. Limit automatic
destruction to explicit test roots/state and protect retained subscriptions,
state storage, hierarchy and access configuration. Do not attach automatic cleanup
to ordinary platform main applies. Failure handling remains pending decision 052.

Question: Should destroy workflows be manually started after reviewing a destroy
plan, or should selected module test deployments automatically clean up after
their test pipeline completes?

- Manual: design an explicit destroy-plan review then a separately initiated
  destroy apply for the intended deployment/state. Do not imply GitHub environment
  reviewer gates are available under the selected Free/private account setup.
- Automatic test cleanup: limit automation to explicitly disposable test roots;
  define failure/cancellation behavior and ownership. Shared-platform and
  bootstrap teardown remain separately initiated, not automatic test cleanup.

Automatic main apply remains as agreed in decision 011. This question concerns
destroy initiation only and authorizes no immediate deletion or workflow run.

### 052 - Failed disposable test cleanup

Status: confirmed by user on 2026-11-14.

Decision: collect diagnostics, then attempt automatic cleanup after disposable
module test failures. Handle cleanup failures, cancellations and runner loss
explicitly; report remaining resources for recovery instead of claiming cleanup
is guaranteed. Shared infrastructure teardown remains separately initiated.

Question: If a disposable module test fails, should cleanup still be attempted
immediately after collecting diagnostics, or should resources remain for manual
investigation and cleanup?

- Cleanup after diagnostics: preserve appropriately protected logs/test results,
  then attempt test-root destruction even after failure. Account separately for
  cancellation, runner loss, partial creates and failed destroy; do not promise
  that an always-run cleanup step guarantees no orphaned resources.
- Retain for investigation: make retention visible and require manual cleanup;
  record ongoing costs and define follow-up so failed tests are not forgotten.

Do not expose secrets, Terraform state or sensitive plan contents in diagnostics.
Shared-platform and bootstrap teardown remain manual regardless of this choice.

### 053 - Official GitHub bootstrap compatibility finding

Status: confirmed by user on 2026-11-14.

Decision: revisit account and plan choices to use the official GitHub bootstrap.
Decisions 008-010 are reopened, not silently replaced with an organization or
paid plan. Existing account remains Free/personal until the user changes it.
No transfer, organization creation, purchase or visibility change is authorized.

Verified on 2026-11-14: the official accelerator GitHub bootstrap explicitly
does not support personal GitHub accounts and requires an organization. It also
states that bootstrap on a Free organization makes repositories public. Therefore
decisions 007-010 (Free/private/personal) cannot use the unmodified alz_github
bootstrap. This should have been established before the extended discovery.

Option A: retain Free/private/personal; generate the official platform starter
through alz_local and build/adapt CI/CD and private ephemeral runner bootstrap
separately. Official platform modules remain the foundation; do not describe
custom personal-account automation as the supported GitHub bootstrap.

Option B: revisit ownership and plan/visibility choices to meet the official
GitHub bootstrap requirements; assess exact capabilities and costs before any
account or repository change. A Free organization alone does not meet private
repository requirements documented for this bootstrap.

Question: retain the account choices and adapt bootstrap separately, or revisit
them to use the official GitHub bootstrap?

Sources:
- [GitHub bootstrap prerequisites](https://azure.github.io/Azure-Landing-Zones/accelerator/1_prerequisites/github/)
- [Local generation option](https://azure.github.io/Azure-Landing-Zones/accelerator/)

### 054 - Visibility requirement under organization bootstrap

Status: confirmed assessment direction by user on 2026-11-14.

Decision: consider a Free GitHub organization with public repositories for the
official bootstrap. This reopens decision 007's private visibility requirement;
it is not authorization to publish files, create repositories or transfer the
existing repository. Assess generated workflows, fork PR trust, runner access,
federation and supported protection controls before confirming this setup.
Decision 039's private-only deployment tfvars policy requires revision if public
visibility is ultimately selected: do not publish existing customer/lab values
without an explicit content review.

Question: Is private deployment repository visibility still a firm requirement,
with willingness to assess a paid organization plan, or should we assess a Free
organization/public repository setup supported by the documented bootstrap?

- Keep private: assess the exact paid plan and bootstrap feature requirements
  before recommending a purchase. Include GitHub subscription cost separately
  from Azure runtime and clarify whether it falls within the GBP 100 target.
- Consider public: reopen decision 007 and review runner trust controls and
  sanitized deployment configuration before publishing anything.

Do not assume a paid organization tier automatically supports every environment
approval feature. Review current GitHub entitlements and accelerator defaults.

### 055 - Organization availability

Status: confirmed by user on 2026-11-14.

Decision: plan a new Free GitHub organization. No existing organization is
selected. Organization creation, repository placement and public content review
remain separate steps; no external changes have been made.

Question: Is there an existing GitHub organization the user controls for this
assessment, or should the plan include creating a new Free organization?

An existing organization name can be supplied as text. Do not create an
organization, transfer repositories or request tokens during requirements
discovery. An organization is managed using a personal login; selecting one does
not require discarding the user's existing personal account.

### 056 - Proposed GitHub organization name

Status: confirmed proposed name by user on 2026-11-14.

Decision: proposed organization name is tapan-patel-github-org. Availability
has not been checked and the organization has not been created. Keep this as a
deployment input rather than embedding it into reusable module implementation.

Question: What name should the new GitHub organization use?

Record the user's preferred name as proposed, not as an available or created
organization. Verify availability and GitHub naming requirements before creation.
Keep customer-specific organization names configurable in the accelerator.

### 057 - Existing repository versus fresh accelerator repositories

Status: confirmed by user on 2026-11-14.

Decision: plan fresh accelerator repositories in the proposed organization;
preserve azure-platform-infra as reference during transition. Carry forward
reviewed decisions and documentation, not all current custom implementation by
default. Preserve local uncommitted work. No new repositories have been created
and no content has been pushed or transferred.

Question: Should we plan fresh accelerator repositories in the proposed
organization and keep the current repository as reference during transition,
or plan to transfer and reuse the current azure-platform-infra repository?

- Fresh repositories: assess the official bootstrap's generated repository
  layout; preserve current local work and carry forward reviewed requirements
  and documentation. Do not publish current ignored configuration implicitly.
- Transfer/reuse: assess bootstrap support for an existing repository, naming,
  workflow/state ownership and content preservation before transfer or generation.

Neither choice authorizes repository creation, transfer, pushes or deletion.
Final repository names and exact bootstrap behavior require separate verification.

### 058 - Deployment configuration in public repositories

Status: confirmed by user on 2026-11-14.

Decision: allow specifically reviewed non-secret lab tfvars to be public in
the new repositories. This revises decision 039's private-only condition for
those reviewed lab files. Do not publish existing ignored files automatically;
review identifiers, naming and network details before each initial publication.
Secrets, keys, Terraform state and sensitive plan contents remain excluded.
Customer-specific publication requires separate customer content review.

Question: For the candidate public organization setup, should repositories contain
only sanitized tfvars examples with actual deployment inputs supplied outside
Git, or may specifically reviewed non-secret lab tfvars be public?

- Sanitized examples only: revise decision 039 for public visibility. Assess
  workflow input storage and generation against Free organization entitlements
  and the official bootstrap. Real input changes outside Git are not necessarily
  covered by the code PR review process.
- Reviewed public lab tfvars: decide exactly which identifiers, names and network
  ranges can be published, never credentials, keys, state or sensitive plan data.
  Existing ignored files are not automatically cleared for publication.

Decision 039 permitted selected tfvars only in a private repository; do not
extend that permission to public repositories without this explicit decision.
Customer deployment configuration remains separately reviewed per customer.

### 059 - PR protection under the public repository option

Status: confirmed by user on 2026-11-14.

Decision: enforce PRs and passing checks before merging main in the proposed
public organization repositories. This supersedes decision 010's manual-only
PR convention for that setup. Automatic main apply remains selected. Review
generated rules, required checks and bypass permissions before implementation;
independent reviewer requirements remain pending decision 060.

Question: Should we restore the original goal of enforced PRs and passing checks
before merging main for the proposed public repositories, or retain the manual
PR convention previously accepted for Free/private repositories?

- Enforce PR and checks: assess bootstrap-generated protections and require
  appropriate successful checks before main updates. Configure independent review
  requirements separately; do not assume a solo author can approve their own PR.
- Manual convention: explicitly retain the procedural limitation despite public
  repository branch protection being available on GitHub Free.

Decision 010 accepted a limitation tied to private Free repositories; do not
carry that limitation into public repositories without reviewing it. Automatic
main apply remains selected. Protection rules and any admin bypass require
implementation review before claiming enforcement.

Reference:
[Protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches).

### 060 - Independent PR approval

Status: confirmed by user.

Decision: require approval from a separate trusted reviewer, plus passing checks
before merging main. Do not substitute self-approval or routine bypass.

Question: Will another trusted person review and approve PRs, or should this
single-operator lab require PRs and passing checks without a mandatory second
person approval?

- Solo lab: the user reviews changes and merges after checks pass; do not
  configure an unattainable independent approval requirement or describe this
  as independently reviewed deployment authorization.
- Independent reviewer: require approval from a separate trusted collaborator;
  agree permissions and stale-review behavior before configuring protection.

GitHub PR authors cannot approve their own PRs. Do not solve this by routinely
bypassing the protection being designed. Customer approval requirements remain
separate from the initial solo lab configuration.

### 061 - Trusted reviewer identity

Status: pending concrete reviewer identity.

User answered "someone". Treat this as a placeholder, not a verified GitHub
username or authorization to invite an account named someone. Continue discovery
with reviewer identity pending. Independent approval remains required by decision
060; identify an eligible reviewer before enabling the protected merge process.

### 062 - Platform subscription readiness

Status: partial readiness reported by user; exact mapping pending.

Answer: some platform subscriptions are available and others are still pending.
Do not assume which ones beyond the previously confirmed Identity subscription.

Question: Besides the previously successful Identity subscription, are the
Connectivity, Management, Observability and Security subscriptions now created
and usable, or are any still pending?

Earlier creation attempts for those four timed out and billing eligibility was
unresolved. Do not infer current readiness from intended names or old plans.
Collect current subscription IDs or verify read-only availability before filling
the accelerator inputs. Preserve existing subscriptions and alias ownership.

### 063 - Available platform subscription mapping

Status: names, IDs and Enabled state supplied by user from refreshed CLI output.

User reports these subscriptions available:

| Platform area | Reported subscription name | Subscription ID | State |
| --- | --- | --- | --- |
| Management | sub-management-shared-001 | 362fd75d-bba6-4016-9df8-e2f783081d58 | Enabled |
| Identity | sub-azlab-identity-shared-001 | d9d326a1-9d3d-4a80-8ac7-06a514e605f8 | Enabled |
| Observability | sub-azlab-observability-shared-001 | c103c9f2-d458-4b5e-8f96-28b5b412a6c2 | Enabled |

Connectivity and Security remain pending based on the reported list. Preserve
the Management name exactly as supplied; do not insert azlab silently. Names
are not subscription IDs and may not be unique. Verify IDs and tenant before
populating accelerator configuration. Previously recorded Identity ID is
d9d326a1-9d3d-4a80-8ac7-06a514e605f8; confirm it against the current inventory.

The refreshed lab-tenant CLI output supplied by the user confirms the Identity
ID above. Management is the original lab subscription, now reported under its
new name; the retained tfstate account is therefore already in the selected
bootstrap subscription. Do not create a duplicate Management subscription.

### 064 - Pending platform subscription provisioning

Status: confirmed by user; awaiting externally created subscription IDs.

Decision: the user will create Connectivity and Security subscriptions separately
and provide their IDs. Do not prepare a Terraform creation retry for these
prerequisites or repurpose another platform subscription as a silent substitute.
Keep later reusable subscription vending as the separately agreed next phase.

Question: For the pending Connectivity and Security subscriptions, should we
prepare repeatable Terraform provisioning using the reviewed billing scope, or
will the user create them separately and provide their IDs?

- Terraform: retain the accelerator's existing-subscription prerequisites and
  prepare subscription creation as a preceding stage. Reconcile aliases/state
  and billing eligibility before retrying previously failed creation.
- User-provided: accept pre-created subscription IDs as deployment inputs;
  preserve reusable vending support as a separate capability for later use.

Neither option authorizes immediate subscription creation or assumes that the
platform accelerator creates its own prerequisite subscriptions.

## Current prerequisite checkpoint

Implementation update: the user requested local YAML/tfvars under alz. Prepared
alz/inputs.yaml, alz/platform-landing-zone.tfvars and the supporting hierarchy
library. See alz/README.md for placeholders, validation and remaining adaptations.
No publication, subscription creation, bootstrap or Azure deployment was performed.

Latest user direction: assume prerequisites are complete for a step-by-step
deployment guide; do not continue prerequisite questions before delivering it.
See alz-deployment-guide.md. This assumption is instructional, not evidence of
actual resource creation or authorization to deploy. Earlier pending IDs remain
historical discovery notes rather than blockers to writing the guide.

- Await Connectivity and Security subscription IDs from the user; validate the
  intended tenant and Enabled state before deployment.
- Proposed organization tapan-patel-github-org has not been verified as available
  or created; fresh accelerator repositories are planned, not created.
- Trusted reviewer remains unidentified ("someone" was treated as a placeholder).
- Preserve subscriptions, tfstate storage, local changes and existing ownership
  until the initial clean foundation transition is explicitly reviewed.
- Public organization setup still requires generated-workflow trust assessment;
  no account, repository, deployment or teardown actions have been performed.

Question: Which of Connectivity, Management, Observability and Security are
available now? Request their subscription IDs if handy, or collect IDs later.
Treat reported availability as user-provided until verified read-only; do not
start subscription creation or fill missing IDs with the original lab ID.

## Official references

- [Microsoft implementation guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/implementation-options)
- [Terraform platform starter](https://azure.github.io/Azure-Landing-Zones/accelerator/starter-terraform/)
- [AVM subscription vending](https://azure.github.io/Azure-Landing-Zones/sub-vending/tf/)
