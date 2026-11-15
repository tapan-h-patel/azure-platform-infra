# Repository working instructions

## Branches and approval

- Check the current branch and working tree before editing.
- If on `main`, create a separate working branch before making changes.
- Preserve existing user changes.
- Keep changes local for user review. Commit, push, and open a pull request only
  after the user authorizes those actions. Never push directly to `main`.

## Keep documentation current

- Update relevant documentation in the same change as implementation; do not
  wait for a separate user request.
- Keep README.md accurate about the layout, setup steps, and implementation status.
- Update docs/architecture.md for architecture changes and decisions.
- Update docs/naming-convention.md for naming rules, prefixes, or tag changes.
- Update module READMEs for inputs, outputs, prerequisites, and usage.
- Update sanitized configuration examples when variables or backend settings change.
- Document authentication, state migration, validation, deployment, and recovery
  steps when those capabilities are implemented.
- Clearly distinguish implemented behavior from planned work. Do not claim a
  check, deployment, or security control exists unless it has been implemented.

## Reusable accelerator

- For ALZ accelerator adoption, consult docs/alz-adoption-decisions.md. Ask one
  decision question at a time and record the user's answer before proceeding.
  Distinguish confirmed decisions from recommendations and pending questions.

- For subscription vending changes, follow docs/subscription-vending-design.md.
  Creation/placement alone is not the complete baseline. Preserve existing alias
  state, stage deployment across subscription boundaries, and give every policy,
  diagnostic setting, IPAM allocation, peering and route table one owner.
  Distinguish target design from capabilities actually implemented and verified.

- Put resource declarations in reusable modules. Deployment roots compose module
  calls, inputs, outputs, provider/backend configuration and state-move declarations;
  do not declare Azure resources directly in deployment roots.
- Parameterize deployment-specific module arguments through root variables and
  each root's ignored terraform.tfvars. Keep sanitized examples current. Preserve
  module-output references for dependencies. Backend blocks, module source paths
  and version pins stay explicit configuration where input variables are not supported.
- Use descriptive Terraform resource labels such as `management_group` or
  `subscription_association` rather than generic labels such as `this`.
- Follow docs/accelerator-design.md. Treat this lab as the first consumer of a
  reusable customer deployment template.
- Keep tenant IDs, subscription IDs, customer names, regions, network ranges,
  environment names, and sizing configurable. Do not embed the current user's
  identifiers into reusable modules or shared examples.
- Keep reusable modules independent of environment roots and backend settings.
- Separate state and access boundaries between customers and environments.
- Keep secrets and state out of source control. Prefer Azure CLI locally and
  federated workload identity for automation; use least-privilege role assignments.
- Follow ALZ decision 058, which supersedes decision 039's private-only condition:
  specifically reviewed non-secret lab tfvars may be public. Keep existing ignored
  files excluded until content review; retain sanitized examples and never publish
  credentials/state. The local alz draft does not authorize publication or apply.
- Select and document compatible Terraform/provider versions during implementation;
  commit root lock files. Review relevant official documentation when choosing
  Azure security settings and resource-specific constraints.
- Run checks appropriate to the change and report what was actually verified.
- Keep work incremental. Do not provision Azure resources or expand into unrelated
  implementation merely because a design document describes future work.
