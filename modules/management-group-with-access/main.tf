module "management_group" {
  source                     = "../management-group"
  name                       = var.name
  display_name               = var.display_name
  parent_management_group_id = var.parent_management_group_id
}
module "scope_access" {
  source                 = "../scope-access"
  scope                  = module.management_group.id
  scope_name             = var.access_name
  scope_type             = "mg"
  group_owner_object_ids = var.group_owner_object_ids
  roles                  = var.roles
}
