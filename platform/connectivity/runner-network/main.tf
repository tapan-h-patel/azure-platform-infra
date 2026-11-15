module "resource_group" {
  source   = "../../../modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
module "runner_network" {
  source                        = "../../../modules/runner-network"
  resource_group_name           = module.resource_group.name
  location                      = var.location
  name                          = var.name
  address_space                 = var.address_space
  container_apps_subnet_cidr    = var.container_apps_subnet_cidr
  private_endpoints_subnet_cidr = var.private_endpoints_subnet_cidr
  state_storage_account_id      = var.state_storage_account_id
  tags                          = module.resource_group.tags
}
