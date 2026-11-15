module "resource_group" {
  source   = "../../../modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
module "runner_environment" {
  source                   = "../../../modules/runner-environment"
  name                     = var.environment_name
  resource_group_name      = module.resource_group.name
  location                 = var.location
  infrastructure_subnet_id = var.infrastructure_subnet_id
  tags                     = module.resource_group.tags
}
