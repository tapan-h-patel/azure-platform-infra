# Connectivity

Shared networking configuration, including hub networks, routing, DNS, private endpoints, and connectivity to deployment operators.

This folder groups configurations by purpose. The first deployable root is
[runner-network](runner-network/README.md), providing a dedicated runner VNet
and private state endpoint/DNS. It has its own deployment/state boundary.
Other connectivity capabilities remain future work.

The [hub-spoke root](hub-spoke/README.md) now composes a hub, multiple spokes,
bidirectional peering, Azure Firewall and workload transit/return routes. It is
independent of the paused runner network and has not been deployed.
