# Azure DevOps option

This is an alternative bootstrap configuration. It does not change the selected
GitHub deployment or create an Azure DevOps organization, project or pipeline.
The copied platform tfvars and library represent the same lab design as the
parent `alz` folder; update both copies together when platform settings change.
The tfvars remains ignored by Git. The library pins ALZ 2026.11.0.

Replace the organization, project, Connectivity and Security subscription IDs
in `inputs.yaml`, and the bootstrap VNet ID in the tfvars. Supply PATs through
the environment variables named in the YAML; do not place tokens in files.
Confirm Azure DevOps permissions, agent registration and independent PR reviewer
before use. The generated pipeline's PR checks, merge protection, apply triggers,
identity separation and one-job agent lifecycle require review and adaptation.

The existing storage reuse, Observability provider mapping, private monitoring,
IPAM and teardown limitations in [the main ALZ README](../README.md) also apply.
Both options use the same proposed network ranges and Azure resources: do not
apply both against the same environment or state without a migration/ownership
plan. No separate backend or state has been created for this option.

After generating the official Azure DevOps starter and completing those
adaptations, use PowerShell 7 in WSL:

```powershell
$alzDevOps = '/mnt/c/github-repos/azure-platform-infra/alz/azure-devops'
Deploy-Accelerator `
  -inputs "$alzDevOps/inputs.yaml", "$alzDevOps/platform-landing-zone.tfvars" `
  -starterAdditionalFiles "$alzDevOps/lib" `
  -output "$alzDevOps/output"
```

Review the bootstrap plan before accepting it. See the [official Azure DevOps
example](https://github.com/Azure/alz-terraform-accelerator/blob/main/templates/platform_landing_zone/examples/bootstrap/inputs-azure-devops.yaml)
and [deployment guide](../../docs/alz-deployment-guide.md).
