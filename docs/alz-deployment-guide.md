# Deploy the platform landing zone with Terraform and Azure Verified Modules

This guide assumes the prerequisites are complete, as requested. It describes
actions for the operator to perform; none have been executed by this guide.
Prepared local inputs now live in [alz](../alz/README.md): review that folder's
documented placeholders and adaptations before using the deployment commands.
It uses the official ALZ accelerator to generate and bootstrap the deployment,
then deploys the platform through GitHub Actions. Workload vending comes later.

Commands marked Bash run in Ubuntu/WSL; PowerShell commands run in PowerShell 7
(`pwsh`) inside the same WSL environment. Do not switch between Windows and Linux
Azure CLI sessions during bootstrap. Their authentication caches are separate.

## 1. Establish the deployment inputs

Use a fresh working directory outside the existing reference repository.
The assumed inputs are:

| Input | Value |
| --- | --- |
| Organization | tapan-patel-github-org |
| Tenant | 846732b8-d571-413b-81e7-4952884e0bb9 |
| Bootstrap / Management subscription | 362fd75d-bba6-4016-9df8-e2f783081d58 |
| Identity subscription | d9d326a1-9d3d-4a80-8ac7-06a514e605f8 |
| Observability subscription | c103c9f2-d458-4b5e-8f96-28b5b412a6c2 |
| Connectivity / Security subscriptions | Your completed prerequisite IDs |
| Deployment region | uksouth |
| Future region, not deployed initially | ukwest |
| Parent management group | Existing Tenant Root group ID, unless a different existing parent is intended |

Use existing subscriptions; the platform starter does not replace subscription
creation prerequisites. Treat these as lab inputs, not reusable module constants.
Keep credentials out of this document, tfvars and committed YAML.

The initial clean rebuild must already have resolved ownership of any existing
management groups. Do not let both the old roots and the accelerator manage the
same scope or subscription placement. Retain the existing state account and
existing state blobs; do not initialize unrelated generated code against an old
state key.

## 2. Authenticate and open PowerShell in WSL

In Bash:

```bash
mkdir -p ~/alz-platform-lab
cd ~/alz-platform-lab
az login --tenant 846732b8-d571-413b-81e7-4952884e0bb9 --use-device-code
az account set --subscription 362fd75d-bba6-4016-9df8-e2f783081d58
az account show --query '{Tenant:tenantId,Subscription:id,Name:name}' -o table
pwsh
```

The subscription must be Management and the tenant must match the table above.
PowerShell 7, Azure CLI, Git and the Terraform version required by the selected
accelerator release are assumed installed. Use the generated release's compatible
version set; do not force the reference repo's provider pins onto new AVMs.

## 3. Install ALZ and generate scenario 6

In PowerShell 7:

```powershell
Install-PSResource -Name ALZ -Scope CurrentUser
Import-Module ALZ
Get-Module ALZ | Select-Object Name, Version

$alzWork = Join-Path $HOME 'alz-platform-lab'
New-AcceleratorFolderStructure -iacType terraform -versionControl github -scenarioNumber 6 -targetFolderPath $alzWork
Get-ChildItem (Join-Path $alzWork 'config')
```

If ALZ is already installed, deliberately select the installed release or update
it before generating files. Record its version and retain the generated module
versions and lock files. Do not regenerate an existing configured directory
blindly when upgrading.

Scenario 6 is the full single-region hub/spoke starting point, not an SMB
subscription consolidation. It fits the agreed initial UK South deployment.
The generated configuration and bundled library are the schema reference for
that release. [Generation instructions](https://azure.github.io/Azure-Landing-Zones/accelerator/2_bootstrap/advanced/),
[scenario 6](https://azure.github.io/Azure-Landing-Zones/accelerator/starter-terraform/scenarios/single-region-hub-and-spoke-vnet-with-azure-firewall/).

## 4. Configure bootstrap inputs

Open `config/inputs.yaml` in your editor. Populate its generated fields rather
than replacing it with a partial example from another release.

| Setting / generated prompt | Choose |
| --- | --- |
| Infrastructure / starter | Terraform / platform_landing_zone |
| Version control | GitHub, organization tapan-patel-github-org |
| Repositories | Fresh organization repositories; preserve this reference repo |
| Bootstrap location and subscription | UK South / Management |
| Existing parent management group | Tenant Root group ID |
| Platform subscription IDs | Actual Management, Connectivity, Identity and Security IDs |
| `use_private_networking` | true |
| `use_self_hosted_runners` | true |
| Reviewer / approver inputs | The actual trusted GitHub reviewer, not the placeholder “someone” |

Supply the completed prerequisite GitHub credentials through the supported
bootstrap mechanism; do not commit token-bearing configuration. Review generated
files for credentials before any publication. Scope runner registration credentials
to the generated deployment repository once bootstrap permits it.

Set a separate bootstrap network reservation, for example `10.64.4.0/24`, with
Container Instances `10.64.4.0/26` and private endpoints `10.64.4.64/26`. These are
**proposed implementation allocations**, not previously approved deployed ranges.
They fit the UK South pool and avoid the hub `10.64.0.0/22`; reconcile them with
the final IPAM reservations before applying. The default bootstrap uses its own
networking and NAT egress: hub-firewall egress integration is a separate change,
not something `use_private_networking` automatically provides.

**Existing state account:** retain `sttfstateshareduksplt001` in
`rg-tfstate-shared-uks-001`. Check the selected bootstrap module's inputs for
existing-storage support before deployment. If reuse is unsupported, adapt its
bootstrap composition to reference the existing account and explicitly create
only the needed private endpoint/access/container configuration. Do not substitute
an invented `existing_storage_account` input or allow a default to replace the
account. New platform and bootstrap states need distinct keys and one owner each.
This reuse adaptation is not implemented in this reference repo.

[Bootstrap networking and configuration review](https://azure.github.io/Azure-Landing-Zones/accelerator/2_bootstrap/).

## 5. Configure the platform tfvars

Edit `config/platform-landing-zone.tfvars`; keep the complete generated file.
For initial deployment set:

```hcl
starter_locations = ["uksouth"]
```

Keep UK West's pool reservation in the address plan; adding a region to active
deployment inputs can create resources, so do not add UK West merely to record it.

Inside the existing `custom_replacements.names` map, change the generated entries:

| Entry | Initial value |
| --- | --- |
| `primary_firewall_sku_tier` | "Basic" |
| `primary_firewall_enabled` | true |
| `primary_firewall_management_ip_enabled` | true |
| `primary_virtual_network_gateway_express_route_enabled` | false |
| `primary_virtual_network_gateway_vpn_enabled` | false |
| `primary_bastion_enabled` | false |
| `primary_private_dns_resolver_enabled` | false |
| `primary_private_dns_zones_enabled` | true |
| `ddos_protection_plan_enabled` | false for the initial cost-controlled lab proposal |
| `primary_hub_virtual_network_address_space` | "10.64.0.0/22" |
| `primary_firewall_subnet_address_prefix` | "10.64.0.0/26" |
| `primary_firewall_management_subnet_address_prefix` | "10.64.0.64/26" |

Review every remaining subnet prefix inherited from the example: none may retain
`10.0.0.x` values outside the hub. Disable unused subnet definitions where the
schema supports it, or allocate valid nonoverlapping ranges in the hub. Review
`primary_hub_address_space` and route prefixes independently; a broad regional
summary must not accidentally override intended spoke routes.

Set resource names/tags using the naming convention and provide the real security
contact where requested. Do not append a second `custom_replacements` block.
Private endpoints protect supported service data paths; the firewall's egress and
management public IPs are not private-endpoint resources and do not imply opening
inbound application access.

The flags above come from the official scenario example; defaults and schema can
change between releases. [Scenario configuration](https://raw.githubusercontent.com/Azure/alz-terraform-accelerator/refs/heads/main/templates/platform_landing_zone/examples/full-single-region/hub-and-spoke-vnet.tfvars),
[Basic SKU customization](https://azure.github.io/Azure-Landing-Zones/accelerator/starter-terraform/options/firewall-sku/).

## 6. Apply your custom hierarchy through the ALZ library

Edit the architecture definition in `config/lib` and select its name through
`management_group_settings.architecture_name`. Preserve the file naming/schema
from the generated library. Define the entire hierarchy, not just added leaves:

```text
Tenant Root (existing parent)
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

Map the agreed mg-* IDs and parent IDs explicitly. Retain relevant built-in
archetypes on the scopes for which they apply; define or compose custom
archetypes for Observability and environment-specific workload scopes. Do not
attach every platform policy to every added group or assume renaming the default
groups produces this architecture. For each selected archetype inspect inherited
policy definitions, assignments and role assignments.

Update `management_group_settings.subscription_placement` to target your IDs,
including Observability. Do not run the old subscription association roots
against the same placements after the accelerator takes ownership.

[Custom architecture instructions](https://azure.github.io/Azure-Landing-Zones/terraform/howtos/modifyingmghierarchy/).

## 7. Complete the agreed platform-specific extensions

These are configuration/implementation tasks before the full agreed design can
be claimed complete. They are not all one-click defaults of scenario 6:

| Requirement | Required action |
| --- | --- |
| Observe policy first | Review selected assignments and set supported non-enforcing/audit behavior; do not mechanically convert every effect |
| No paid Defender plans | Modify/remove enabling assignments using the selected library's supported options; do not silently disable existing protections |
| Log Analytics in Observability | Assess starter provider mapping: moving the workspace may require a separate management AVM call under an Observability provider, with output wiring into policy; a resource name change does not move subscriptions |
| 30-day searchable logs | Set supported workspace/table retention and document table exceptions |
| Private monitoring | Assess Azure Monitor Private Link Scope, private endpoints and runner query/ingestion DNS paths for the services in scope |
| Central DNS with Basic | Remove firewall DNS-proxy settings and firewall-IP client DNS; use Azure-provided DNS and zone links to each client VNet |
| Scoped access groups | Compose the Entra group/access extension with AVM scopes; create Reader/Contributor/Owner groups and keep operational membership separately managed |
| Separate plan/apply identities | Verify generated federation, Azure/Entra rights, state access and workflow restrictions; do not grant apply credentials to PR jobs |
| Ephemeral private runners | Verify actual one-job runner registration/disposal in the chosen bootstrap release; private hosting alone does not guarantee ephemerality |
| Operational alerts | Add selected AMBA rules/action groups and recipients; do not claim logging itself supplies alerts |
| IPAM | Reserve the agreed pools centrally; validate AVNM/provider integration separately; do not silently add manual spoke allocations |
| Default-deny inter-spoke | Define explicit flows and routes; no direct-spoke mesh bypass |
| Broad HTTPS initially | Restrict sources and protocol scope; record as a lab exception to tighten later |

Use modules for additional Azure resources and variable-driven root calls, as
agreed. Add supported overrides to generated inputs; use separate roots/provider
aliases where lifecycle or subscription boundaries require them. This guide does
not claim the existing custom extensions have already been converted to AVMs.

[Configuration interfaces](https://azure.github.io/Azure-Landing-Zones/accelerator/starter-terraform/configuration/),
[custom library guide](https://azure.github.io/Azure-Landing-Zones/terraform/howtos/modifyingmghierarchy/),
[DNS integration guidance](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration).

## 8. Review and execute bootstrap

Once the configuration and necessary adaptations are ready, run in PowerShell:

```powershell
Deploy-Accelerator -inputs "$alzWork/config/inputs.yaml", "$alzWork/config/platform-landing-zone.tfvars" -starterAdditionalFiles "$alzWork/config/lib" -output "$alzWork/output"
```

Inspect its bootstrap plan before accepting the deployment prompt. It provisions
the delivery foundation and can create GitHub repositories/workflows as well as
Azure resources; it is not a read-only code generator. Verify that retained
storage is not scheduled for replacement, addresses are correct, and no existing
state key is reused accidentally. Preserve the local configuration/output and
bootstrap state locations for recovery.

The bootstrap happens before the GitHub runners exist, using the prepared
operator bootstrap access. Private backend access for later stages comes from
the VNet-connected execution environment, not from local Azure CLI login.

[Official bootstrap procedure](https://azure.github.io/Azure-Landing-Zones/accelerator/2_bootstrap/advanced/).

## 9. Review generated repositories before the first platform deployment

Clone the generated platform repository using its actual name from bootstrap
outputs; do not assume it matches this reference repository. Create a feature
branch before changes. Review generated Terraform, module/provider pins, backend,
lock files and workflows locally.

Configure main to require passing checks and a separate trusted reviewer's
approval. Verify actual status-check names and include administrators in the
intended restrictions. Review public repository PR triggers so fork/untrusted
code cannot execute on private Azure-connected runners. Do not execute a public
PR checkout using privileged `pull_request_target` credentials.

Check the generated workflow triggers. Your required PR-plan/main-apply behavior
must be verified or adapted; do not assume a manually dispatched starter workflow
already implements it. Keep bootstrap/state configuration isolated from platform
service teardown. Review non-secret tfvars before publishing; never publish
tokens, state or sensitive plans.

Commit/push and open a PR only after the user's local review authorizes it.

## 10. Deploy the platform through GitHub Actions

For the official first-run path, open the generated repository's **Actions** tab,
select **02 Azure landing zone Continuous Delivery**, and use **Run workflow** on
the intended branch. Examine the plan and complete any configured apply approval.
After PR/main automation has been verified, use a reviewed PR for subsequent
changes and let the main workflow apply the merged revision.

Review the exact commit, state key, tenant and target subscriptions. Expected
changes must match the configured UK South footprint and custom hierarchy, not
the stock Premium/gateway/resolver example. Do not apply from your laptop against
private state without a valid private execution path.

[Official first deployment workflow](https://azure.github.io/Azure-Landing-Zones/accelerator/3_run/).

## 11. Validate the result

From the authorized runner or temporary recovery host:

- Confirm all five subscriptions have the intended management group placement.
- Confirm Basic Firewall, management subnet and routing match the plan.
- Test private storage DNS resolution and authenticated backend access from
  the runner network; check public data access is disabled when cutover is ready.
- Verify central DNS links resolve private endpoints from each required VNet.
- Check exported Activity Logs, configured diagnostic logs, actual retention and
  selected alert delivery in Observability.
- Verify scope-specific groups and role assignments; test plan/apply separation.
- Run a fresh normal plan: investigate unintended changes before adding workloads.

An apply success alone does not establish private connectivity, policy compliance,
alert delivery or end-to-end firewall transit. Record the checks actually run.

## 12. Test teardown without deleting the retained foundation

Use distinct roots/state for retained hierarchy/access, platform services,
bootstrap and disposable tests. Automatic test cleanup applies only to disposable
test deployments, after collecting diagnostics, including failed tests.

For a disposable test root, the pipeline sequence is:

```bash
terraform init -input=false
terraform plan -destroy -input=false -out=destroy.tfplan
terraform apply -input=false destroy.tfplan
```

The test root must have no ownership of retained subscriptions, hierarchy, access
or tfstate storage. Handle failures/cancellation and report resources left behind.
Do not run that command against an unsplit full platform root: it could remove
management groups and access you agreed to keep.

Shared-platform and bootstrap teardown are separate manually initiated workflows.
Remove dependent tests first; destroy shared services only after moving execution
to the independent management-host path; remove runners/network dependencies last.
Retain subscriptions, state account/blobs, hierarchy and human access. Bootstrap
rebuild must be possible without the runners or firewall being rebuilt.

The official cleanup helper can remove considerably more than the retained
boundaries here. Its generic removal example is not the lab teardown runbook.
Likewise, bootstrap destroy can delete GitHub delivery resources: do not treat
it as a routine module-test cleanup. [Cleanup reference](https://azure.github.io/Azure-Landing-Zones/accelerator/faq/cleanup/).

## Implementation status

This is a researched operator guide, not an executed or validated deployment.
Prerequisites are assumed complete for the instructions. Custom storage reuse,
Observability placement, split lifecycles, public-runner trust controls and
independent bootstrap recovery need implementation and plan validation against
the selected release. The GBP 100/month target at 20 active hours is not a
verified estimate; private endpoints and retained services can charge when no
test job is running.
