# Subscription vending deployments

These roots currently implement creation and management group placement only.
See [the governed vending design](../../docs/subscription-vending-design.md) for
the target RBAC, logging, governance, budget and optional connected networking
baseline. The wider service and its profile workflow are not implemented yet.

This directory is navigation only. Run Terraform from one of the deployment roots:

```text
platform/             # Five shared platform subscriptions
workloads/
  dev/                # Development workload subscriptions
  uat/                # UAT workload subscriptions
  prod/               # Production workload subscriptions
```

- [Platform deployment](platform/README.md)
- [Workloads overview](workloads/README.md)

Each leaf root calls the same reusable subscription-vending module. It owns its
own terraform.tfvars, provider configuration, outputs, lock file and backend key.
No root contains resource blocks or hardcoded module deployment arguments.

The Platform folder preserves the former root's backend key
azlab/foundation/subscriptions.tfstate so no state ownership is lost. The workload
roots use azlab/foundation/subscriptions/workloads/<environment>.tfstate. Backend
settings are explicit in each backend.tf; customer copies must update them before
initialization. Never share state keys across roots/customers.

The folder move does not change Platform resource addresses or migrate remote
state. Existing local files/cache were moved into platform, not discarded. Old
saved plans were retained as ignored files but must not be applied after this
restructure: initialize and generate a fresh plan from the chosen leaf directory.
No subscription creation or apply has been run during this change.
