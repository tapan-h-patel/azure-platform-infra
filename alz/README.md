# ALZ accelerator configuration

The separate [Azure DevOps option](azure-devops/README.md) contains its own
bootstrap YAML, platform tfvars and library. Keep its platform copy synchronized.

Local configuration for the official Terraform `platform_landing_zone` starter,
based on scenario 6 (single-region hub/spoke). This folder contains inputs, not
a Terraform deployment root: do not run `terraform init` or `apply` here.

| File | Purpose |
| --- | --- |
| inputs.yaml | GitHub/Azure bootstrap inputs, with known lab IDs populated |
| platform-landing-zone.tfvars | Platform hierarchy, placement, Basic Firewall and central DNS inputs |
| lib/alz_library_metadata.json | Dependency on ALZ library platform/alz 2026.11.0 |
| lib/architecture_definitions/ | Eleven-management-group custom hierarchy |
| lib/archetype_definitions/ | Explicit reduced baseline, excluding automatic deployment/paid-plan assignments |

The tfvars file remains ignored by the repository's existing rule. It exists
locally for review; this change does not authorize publishing it. YAML contains
no tokens. Set bootstrap credentials in the environment using
`TF_VAR_github_personal_access_token` and
`TF_VAR_github_runners_personal_access_token`; never put their values in Git.

## Values to replace

- `REPLACE_CONNECTIVITY_SUBSCRIPTION_ID` and `REPLACE_SECURITY_SUBSCRIPTION_ID`
  in inputs.yaml with actual prerequisite IDs.
- `REPLACE_BOOTSTRAP_VNET_RESOURCE_ID` in the tfvars with the resulting bootstrap
  VNet resource ID, before deploying the platform DNS links. Bootstrap deployment
  and platform deployment are separate stages.
- Select the actual trusted PR reviewer in branch protection. `apply_approvers`
  is empty deliberately: it controls an additional apply-environment approval,
  not the required independent PR review. Review generated branch rules and
  PR/main triggers rather than assuming defaults implement every agreed control.

The proposed bootstrap range 10.64.4.0/24 fits the agreed UK South pool and is
disjoint from hub 10.64.0.0/22. Record it with IPAM before implementation. UK West
and On-prem networks are address reservations only; no gateway or UK West hub
is enabled. Only the initial blob, Key Vault and registry private DNS zones are
selected; add monitoring/service-specific zones with their integrations.

## Required implementation before a full deployment

These files are a reviewable configuration draft, not a claim that the stock
bootstrap implements all requirements:

1. **Reuse existing state storage.** The reviewed bootstrap schema has no
   existing-account input. Adapt its composition/ownership to retain
   sttfstateshareduksplt001 in rg-tfstate-shared-uks-001 and container tfstate,
   using distinct state keys. Do not apply the unmodified bootstrap expecting
   it to reuse the account; it would provision its default storage instead.
2. **Observability provider.** The stock starter deploys management resources
   through `azurerm.management`. `management_resources_enabled = false` prevents
   deployment into that subscription. The configured private, 30-day workspace
   settings are inactive until a separate AVM call/provider mapping targets
   c103c9f2-d458-4b5e-8f96-28b5b412a6c2. Add AMPLS/private endpoints, exported logs,
   diagnostics and selected AMBA rules; they are not created by these inputs.
3. **Access and runners.** Add scoped Entra groups/role bindings, verify separate
   plan/apply identity restrictions, fresh-per-job disposal and public-repository
   PR trust. Bootstrap private networking does not automatically route runner
   egress through the platform firewall.
4. **Routing and IPAM.** AVNM allocations and spokes are later integrations.
   The firewall has no allow rules here (default deny); add the agreed scoped
   outbound HTTPS lab exception through a supported firewall-policy module.
   Do not claim spoke transit is tested before spokes/routes exist.
5. **Lifecycle separation.** Split retained hierarchy/access from disposable
   platform services and bootstrap before implementing destroy workflows. The
   generated starter can combine them; a whole-root destroy would not preserve
   the agreed retained foundation. Build the independent recovery-host path.

The selected observe-first baseline retains six root, three Identity and eight
Workloads assignments, all with enforcement disabled. Other inherited assignment
attachments are removed by the overrides; policy definitions remain available.
This intentionally does not deploy logging/Defender/backup/remediation services
through defaults. It is a starting policy selection, not the full ALZ control
set or a validated customer governance baseline. Review before expanding it.

## Use with the accelerator

From WSL PowerShell 7, after generating the official starter and completing the
adaptations above, use these input paths instead of overwriting them by generating
new defaults into this folder:

```powershell
$alzConfig = '/mnt/c/github-repos/azure-platform-infra/alz'
Deploy-Accelerator `
  -inputs "$alzConfig/inputs.yaml", "$alzConfig/platform-landing-zone.tfvars" `
  -starterAdditionalFiles "$alzConfig/lib" `
  -output "$alzConfig/output"
```

Review the bootstrap plan before accepting any apply prompt. Assumed prerequisites
do not supply missing IDs or resolve storage ownership automatically. Follow the
[deployment guide](../docs/alz-deployment-guide.md) for the complete sequence.
No bootstrap, Azure plan, apply, GitHub publication or destroy was run here.

Local checks passed: YAML/JSON parsing, bootstrap top-level keys against the
official variable names, eleven unique hierarchy IDs with valid parent references,
and Terraform formatting. A provider-free temporary harness also accepted the
platform tfvars against the downloaded official core, management and hub input
types. It excluded subscription bootstrap values and used permissive support
variables for connectivity resource groups/virtual WAN; this is not a full
accelerator validation, library expansion or Azure-connected plan.

## Source references

Schema reviewed against the official repositories on 2026-11-14. Select and pin
a compatible accelerator release during generation; recheck these inputs when
changing releases.

- [Official GitHub bootstrap example](https://github.com/Azure/alz-terraform-accelerator/blob/main/templates/platform_landing_zone/examples/bootstrap/inputs-github.yaml)
- [Bootstrap variable schema](https://github.com/Azure/accelerator-bootstrap-modules/blob/main/alz/github/variables.tf)
- [Platform input schema](https://github.com/Azure/alz-terraform-accelerator/tree/main/templates/platform_landing_zone)
- [Pinned policy archetypes](https://github.com/Azure/Azure-Landing-Zones-Library/tree/platform/alz/2026.11.0/platform/alz/archetype_definitions)
