output "runner_environment_id" {
  description = "Container Apps environment ID for later runner job provisioning."
  value       = module.runner_environment.id
}
