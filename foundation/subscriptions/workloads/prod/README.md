# prod workload subscription vending

Independent Terraform root calling modules/subscription-vending. The inputs are
supplied by this directory's terraform.tfvars; no resource blocks are in the root.
The example creates sub-example-workloads-prod-001 and associates it with
mg-example-prod. The ignored local lab file uses sub-azlab-workloads-prod-001,
mg-prod, and the previously discovered MCA billing scope. Review those
values and actual billing/placement rights before planning.

This root owns only its subscription aliases and management group associations.
It does not create management groups, applications, identities or extra access
groups. Management group RBAC/policy inherits into the subscription. The existing
lab subscription is not moved or adopted. Billing workload is Production in the
example: that is an offer classification, separate from environment prod;
use DevTest only with an eligible offer.

From the repository root in WSL:

```bash
cd foundation/subscriptions/workloads/prod
terraform init
terraform validate
terraform test
terraform plan -out=subscriptions.tfplan
```

Review the two planned additions (one subscription plus one association) before
any apply. These subscriptions have not been created by the agent. Mocked tests
do not validate real billing rights. A failure after creation can leave a live
subscription; preserve state and generate a recovery plan rather than a new alias.

Backend settings are explicit in backend.tf. This root uses the separate lab key
azlab/foundation/subscriptions/workloads/prod.tfstate. Update backend settings
for customer deployments before initialization. Never use another root's key.
Provider and module subscription deletion protection are enabled. Decommissioning
is a separate billing/ownership operation; do not treat subscription destroy as
routine test cleanup. Actual input values stay in ignored terraform.tfvars and
sanitized terraform.tfvars.example is the template.

See the [shared module](../../../../modules/subscription-vending/README.md) for
billing scope formats, inputs/outputs, permissions and lifecycle details.
