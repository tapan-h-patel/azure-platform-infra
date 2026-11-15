# Resource group

Creates one Azure resource group. Required inputs: `name` and `location`.
Optional `tags` defaults to an empty map. Outputs: `id`, `name`, `location`, `tags`.
Naming and baseline tags are supplied by the deployment caller. Authentication
and backend settings are inherited from the caller, not configured here.

Used by runner deployment roots and the tfstate-storage composition. The module
does not add deletion guards, locks, RBAC, or policies. Review deletion plans:
deleting a resource group can delete its contained resources. Compatible versions
are Terraform >=1.17.2,<2 and AzureRM >=5.14,<6; roots pin exact versions.
