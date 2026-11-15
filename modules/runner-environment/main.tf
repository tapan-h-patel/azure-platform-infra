resource "azurerm_container_app_environment" "runner_environment" {
  name                           = var.name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = true
  public_network_access          = "Disabled"
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
  tags = var.tags
}
