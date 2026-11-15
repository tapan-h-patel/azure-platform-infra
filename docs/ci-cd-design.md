# Private self-hosted CI/CD design

## Decision and current status

The repository is a public personal GitHub repository. Use ephemeral GitHub Actions
runners in Azure Container Apps Jobs; hosted-runner VNet integration requires an
eligible GitHub organization and is not the chosen route.

Stage 1 is implemented locally: a dedicated VNet, two subnets, state blob private
endpoint/DNS and an internal Container Apps environment. No runner job, image,
GitHub registration, deploy identity, secrets, workflow, or deployment has been
created. Do not interpret the environment output as a functioning runner.

## Ownership and order

1. platform/connectivity/runner-network owns runner network and private state access.
2. platform/management/github-runners owns the Container Apps runner environment.
3. Next: build a pinned Terraform/Azure CLI runner image and single-use jobs.
4. Configure trusted runner registration, separate plan/apply OIDC identities,
   Azure and Graph access, workflow restrictions, monitoring, and concurrency.
5. Enable PR checks and protected-main deployment only after end-to-end testing.

Each root owns a separate state key. Outputs are explicit inputs to the next
stage; no root reads every other root's state. Bootstrap locally before a pipeline
can manage its own runner dependencies. Don't destroy runner networking mid-apply.

## Public repository trust boundary

Do not execute arbitrary fork PR code inside the VNet. Even terraform plan can run
provider/external code, access state, and use the job's credentials/network.
Ephemeral containers limit persistence but do not remove that exposure.

Preferred route for unrestricted automatic internal PR plans: a private repository
with trusted contributors and protected workflow changes. If the accelerator stays
public, run public PR formatting/validation/tests on GitHub-hosted runners without
Azure credentials. Only explicitly trusted maintainer-approved code may enter
private plan jobs, using a trusted workflow/control path. A fork approval click
or self-hosted label is not a sufficient security architecture. Do not use
pull_request_target to check out and execute untrusted PR code with credentials.
This trust policy remains to be selected before runner registration/workflows.

## Planned execution model

PR: checks and a plan after trust gating; no Azure resource write permissions.
Merge to protected main: plan the exact merged commit, then apply that saved plan.
PR preview is not a guarantee of the post-merge plan because state/commit may differ.
Serialize applies per state and retain Azure lease locking. Protect plan artifacts
and apply jobs; restrict deploy OIDC trust to the intended repo/ref or protected
environment, using the actual repository subject format when configuring trust.
Separate plan and apply identities; no client secrets or broad Azure roles on
runner hosts. Graph read/write requirements differ from Azure resource RBAC.

Use a short-lived registration/JIT approach or tightly scoped registration
controller; registration authentication and an event scaler need their own design.
Do not put a reusable GitHub admin token into untrusted job execution. Azure jobs
must expire after one workflow job; externalize operational logs before teardown.
Container Apps Jobs do not support Docker-in-Docker workflows.

## Network and access

Runner subnet is exclusively delegated to ACA; private endpoints use a separate
subnet. Private DNS links the normal blob hostname to the account's private IP.
Entra blob data permissions are still required. The storage public access setting
is unchanged until private runner and operator recovery access are verified.
A laptop needs VPN/routing/private DNS to use a private-only backend.

No public application ingress is enabled. This is not an air-gapped design:
GitHub, Entra, Azure management/Graph APIs, image registries and Terraform providers
need controlled outbound connectivity. The initial network has no custom NSG,
firewall/egress allowlist, peering or VPN. Add controls without breaking ACA service
requirements. Diagnostic export, image provenance and recovery procedures remain
next-stage requirements; this is not a production-ready runner platform.

## References

- [Microsoft's ephemeral runner jobs pattern](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs)
- [Container Apps VNet requirements](https://learn.microsoft.com/en-us/azure/container-apps/custom-virtual-networks)
- [Storage private endpoints](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [GitHub self-hosted runner security](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub OIDC with Azure](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
