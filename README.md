# Azure platform infrastructure

Azure Terraform for the lab. Kubernetes manifests live in aks-git-ops; application source and image builds live in app1.

The lab is the first consumer of a reusable customer platform accelerator.
The [alz configuration folder](alz/README.md) contains the local bootstrap YAML,
platform tfvars and supporting custom hierarchy/library files for ALZ adoption.
It is a draft input set; storage reuse and other extensions are documented there.
See the [step-by-step ALZ AVM deployment guide](docs/alz-deployment-guide.md)
for the official accelerator workflow and the adaptations required by this lab.
Tenant, subscription, region, environment, naming, and sizing will be configurable.
See [accelerator design](docs/accelerator-design.md) for boundaries and principles.

The [ALZ adoption decision record](docs/alz-adoption-decisions.md) tracks the
ongoing, one-question-at-a-time assessment of the official Terraform accelerator
and Azure Verified Modules. Adoption and state transitions are not yet approved.

The [governed vending design](docs/subscription-vending-design.md) defines the
common baseline (RBAC, logging, governance and budgets), connected/isolated
profiles, central AVNM/IPAM ownership and staged delivery. It includes a
documentation-only request example. The wider baseline is not implemented;
current subscription roots create subscriptions and management group placement.

## Layout

- bootstrap/tfstate: separate root for remote state storage.
- [foundation/management-groups](foundation/management-groups/README.md): separate hierarchy and scoped group/RBAC deployment root.
- [foundation/subscriptions](foundation/subscriptions/README.md): navigation for separate Platform and workload Dev/UAT/Prod subscription-vending roots.
- [modules/subscription-vending](modules/subscription-vending/README.md): reusable subscription creation and placement, accepting EA/MCA/MPA billing scopes.
- [platform](platform/README.md): navigation folders for connectivity, identity, management, observability, and security.
- [platform/connectivity/hub-spoke](platform/connectivity/hub-spoke/README.md): module-only VNet topology, Azure Firewall, peerings and firewall transit routes.
- [workloads](workloads/README.md): navigation folders for dev, prod, and uat workloads.
- environments/lab: earlier lab scaffold, retained until its future deployment placement is decided.
- modules: reusable networking, ACR, and AKS modules.
- [modules/management-group](modules/management-group/README.md): reusable tenant hierarchy building block for foundational platform components.
- [modules/management-group-with-access](modules/management-group-with-access/README.md): creates a management group with its scoped access.
- [modules/scope-access](modules/scope-access/README.md): creates security groups and Azure role bindings for an explicit scope.
- .github/workflows: future Terraform PR checks.
- docs/architecture.md: architecture and decisions.
- [docs/naming-convention.md](docs/naming-convention.md): resource naming patterns, examples, and tags.

```text
bootstrap/tfstate/
foundation/management-groups/
foundation/subscriptions/
  platform/
  workloads/
    dev/
    uat/
    prod/
platform/
  connectivity/
  identity/
  management/
  observability/
  security/
workloads/
  dev/
  prod/
  uat/
modules/
docs/
```

Platform and Workloads folders mirror hierarchy responsibilities for navigation.
Their existence does not define Terraform roots, state boundaries, or Azure
deployment targets. Tenant Root and Intermediate Root are omitted from the path
to avoid unnecessary nesting. Existing Terraform configuration has not moved.

The [state bootstrap](bootstrap/tfstate/README.md) is implemented for local review
and validation. It creates state storage with Entra access, firewall rules, and
recovery settings when applied. The user tested it with LRS and then destroyed
the test deployment. Management group and subscription creation modules are implemented.
Networking reference modules remain under review; ACR, AKS, the lab environment,
and CI workflows remain placeholders. Remote backend migration
is a documented post-deployment step.

Private endpoint state storage is the next networking design direction; the
current bootstrap still uses an IP-restricted public endpoint.

The [self-hosted CI/CD design](docs/ci-cd-design.md) now has a local first stage:
runner network/private state endpoint under platform/connectivity/runner-network
and internal Container Apps environment under platform/management/github-runners.
Nothing from this stage has been deployed. Actual runner jobs and workflows remain
pending, including a trusted PR policy for this currently public repository.

## Working process

All deployment roots pin Terraform **1.17.2** and AzureRM **5.14.0** exactly. Terraform
1.17.2 was the latest stable release verified on 2026-11-13. Pins remain fixed
until an explicit upgrade is reviewed; they do not automatically follow latest.
The `.terraform-version` file supports compatible CLI version managers.

Create a separate branch before changing main. Review locally before committing, pushing, or opening a pull request.

Commit sanitized examples and generated .terraform.lock.hcl files. Keep credentials, state, actual variable files, and saved plans out of Git.

Keep documentation and examples updated with implementation changes, following
[repository instructions](AGENTS.md). The scaffold is not yet production-ready.

Set deployment-specific module arguments in each root's ignored terraform.tfvars;
terraform.tfvars.example provides the sanitized interface. Root module calls use
variables and dependency outputs. Backend blocks, module source paths and version
pins remain explicit configuration. The environments/lab placeholder currently
has no module calls or deployment inputs.

The foundation additionally pins AzureAD 3.9.0. See [scope-based access](docs/access-model.md) for naming, role inheritance and membership ownership.
