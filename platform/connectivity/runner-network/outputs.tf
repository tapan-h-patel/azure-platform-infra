output "container_apps_subnet_id" {
  description = "Copy this explicit ID into the runner environment deployment inputs."
  value       = module.runner_network.container_apps_subnet_id
}
output "virtual_network_id" {
  description = "Runner VNet ID for future peering and DNS integration."
  value       = module.runner_network.virtual_network_id
}
output "state_private_endpoint_id" {
  description = "State storage blob private endpoint ID."
  value       = module.runner_network.state_private_endpoint_id
}
