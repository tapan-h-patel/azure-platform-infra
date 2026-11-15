# Terraform checks

Terraform and AzureRM versions are pinned in all deployment roots. Add terraform-checks.yml
as a separate implementation step, using the Terraform version recorded in
.terraform-version. It should check formatting and validate bootstrap/tfstate,
foundation/management-groups, and environments/lab with backend initialization disabled.
Run mocked module and foundation tests as well. Deployment automation
will be designed separately.

The chosen self-hosted direction and staged implementation are documented in
../../docs/ci-cd-design.md. The repository is currently public. Do not add an
automatic self-hosted fork PR workflow; public PR checks must not gain private
network or Azure credential access. Runner jobs, trust gating and workflows
remain pending. Include the new runner-network and github-runners roots in
future schema/format checks, and the two new modules' mocked tests.
