# Reusable Azure platform accelerator

## Intent and status

This repository is intended to become a reusable Terraform starting point for
customer Azure tenants and multiple environments. The current lab is its first
consumer. State bootstrap, management group modules, and composed scoped access are implemented;
networking reference modules are implemented but unreviewed; ACR, AKS, and the lab root remain scaffolds. The user tested the
bootstrap with LRS and destroyed it afterward. It is not a production-ready or
validated cross-tenant solution. Private endpoint support remains future work.

## Configuration boundaries

Reusable modules describe capabilities such as management groups, networking, ACR, and AKS.
All resource declarations live in modules, including resource groups and tfstate
storage. Deployment roots compose them with inputs, outputs, providers, backends
and declarative state moves. Refactoring existing addresses must preserve live
state ownership through moved blocks and reviewed plans.
Environment roots compose modules and supply deployment-specific configuration.
Backend configuration belongs to each deployment root, not to reusable modules.
Subscription vending is composed in the separate foundation/subscriptions/platform
and foundation/subscriptions/workloads/dev, uat and prod deployment roots through
modules/subscription-vending, with per-entry billing scopes for EA/MCA/MPA. Creation
eligibility is a billing prerequisite, not implied by Azure resource RBAC or an
existing Free subscription. Preserve aliases and state as billing lifecycle ownership.
All deployment-specific module arguments are root variables populated through
that root's terraform.tfvars. Complete resource group names, environment names,
tags, foundation parent scope and role mappings are explicit deployment inputs.
Module outputs wire dependencies; do not duplicate dependent resource IDs in
tfvars within the same root. Sanitized terraform.tfvars.example files document
the interface, while real files remain ignored. Backend literals, module source
paths and pinned versions remain explicit Terraform configuration.
The `platform/` and `workloads/` navigation folders mirror management group
responsibilities and workload environments. A folder alone does not establish a
deployment root or state boundary. The earlier `environments/lab` scaffold remains
until its deployment placement is decided.
The first concrete platform roots are runner-network under connectivity and
github-runners under management. They currently provide network/private state
connectivity and a Container Apps environment, not a registered runner or pipeline.
Follow [CI/CD design](ci-cd-design.md) before adding trusted jobs or credentials.
Tenant hierarchy is composed separately in `foundation/management-groups` with
its own state and permissions, independent of regional environment lifecycles.
The foundation now composes scopes, Entra security groups and role bindings
together. It leaves operational membership outside Terraform ownership and
requires explicit trusted group owners. Subscription placement is not managed
by this root. See [access model](access-model.md) for inheritance and role choices.

Customer or deployment configuration supplies:

- Tenant and subscription selection.
- Customer/workload identifier, environment, location, and naming tokens.
- Tags and ownership metadata.
- Network address ranges and connectivity requirements.
- Resource sizing, availability, and feature settings.
- State storage location and unique state key.

Use sanitized examples in the template. Keep actual deployment values in the
customer's chosen configuration store or ignored local files. Tenant and
subscription IDs are identifiers, but shared examples must remain portable.
Never store secrets in Terraform examples, source control, or committed plans.

## Isolation and onboarding

Use a customer-owned repository instance or equivalent access boundary for each
customer. Maintain separate state for each customer and environment. The lab's
single-state approach is an initial choice, not a requirement for every customer.
Split states further when lifecycle, ownership, or access needs justify it.

Before a customer deployment, verify target tenant/subscription, permissions,
resource provider availability, regional support, quotas, naming availability,
network ranges, policy constraints, and expected costs. Tenant-specific policies
and prerequisites may require adaptations; this template cannot guarantee an
unchanged deployment into every tenant.

## Implementation principles

- Use explicit deployment inputs and variable validation for supported values.
- Select compatible Terraform and provider versions and commit root lock files.
- Use Azure CLI authentication for local work and federated identity for CI/CD.
- Grant deployment and runtime identities only the permissions they require.
- Grant human state access through Entra security groups. Supply stable group
  object IDs to RBAC assignments and manage membership separately. Avoid direct
  user assignments; design automation identity permissions separately.
- Design state access, locking, recovery, and authentication explicitly.
- Choose network exposure, AKS access, identity, logging, encryption, and recovery
  controls deliberately; record decisions, tradeoffs, and customer prerequisites.
- Separate Azure infrastructure from Kubernetes manifests and application code.
- Add formatting, validation, and appropriate security checks incrementally.
- Review plans before applying; introduce deployment approvals before automated
  delivery. Keep credentials and sensitive plan contents out of logs and artifacts.
- Check current official Azure and Terraform guidance when implementing controls.

These are design requirements. Their presence here does not mean the controls
are already implemented or that the template meets a compliance standard.

## Documentation maintenance

Repository instructions in [AGENTS.md](../AGENTS.md) require documentation updates
with implementation changes. The pull request template prompts reviewers to
check documentation and examples. These are workflow safeguards; automated
documentation generation and drift detection have not been implemented.

Keep module usage, deployment prerequisites, configuration examples, operational
steps, and known limitations accurate as capabilities are added.

## Subscription delivery baseline

Follow [governed vending design](subscription-vending-design.md) for the target
baseline and profiles. Common RBAC, Activity Log export, governance and budget
notifications belong to subscription delivery; connected profiles also consume
central AVNM/IPAM/hub services. These are target capabilities, not completed code.
Avoid duplicating inherited policies/RBAC and conflicting resource diagnostics,
peering or route-table ownership. Preserve existing subscription creation states
and configure the next stage's provider with the returned subscription UUID.
