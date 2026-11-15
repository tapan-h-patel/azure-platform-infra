# Management

Shared platform management infrastructure, operational tooling, and automation services. State storage bootstrap remains in bootstrap/tfstate.

This folder groups configurations by purpose. The first deployable root is
[github-runners](github-runners/README.md), currently the internal Container Apps
environment stage. Actual ephemeral jobs and GitHub workflows are not yet added.
See the [CI/CD design](../../docs/ci-cd-design.md) for trust and networking prerequisites.
