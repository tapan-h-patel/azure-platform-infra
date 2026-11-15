# Workload subscription deployments

Separate deployment roots for [Dev](dev/README.md), [UAT](uat/README.md), and
[Prod](prod/README.md). Each example vends one workload subscription into its
matching existing management group. Add more subscriptions to that root's map
when needed; do not manage one alias or placement in multiple roots.

These folders create subscriptions, not application resources. Application
infrastructure configuration belongs in the repository's top-level workloads
folders. All roots call modules/subscription-vending and receive inputs via tfvars.
