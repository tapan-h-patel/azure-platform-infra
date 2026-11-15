module "intermediate_root" {
  source                     = "../../modules/management-group-with-access"
  name                       = var.root_management_group.name
  display_name               = var.root_management_group.display_name
  access_name                = var.root_management_group.access_name
  parent_management_group_id = var.parent_management_group_id
  group_owner_object_ids     = var.group_owner_object_ids
  roles                      = var.roles
}
module "branches" {
  source                     = "../../modules/management-group-with-access"
  for_each                   = var.branch_management_groups
  name                       = each.value.name
  display_name               = each.value.display_name
  access_name                = each.value.access_name
  parent_management_group_id = module.intermediate_root.id
  group_owner_object_ids     = var.group_owner_object_ids
  roles                      = var.roles
}
module "leaves" {
  source                     = "../../modules/management-group-with-access"
  for_each                   = var.leaf_management_groups
  name                       = each.value.name
  display_name               = each.value.display_name
  access_name                = each.value.access_name
  parent_management_group_id = module.branches[each.value.parent_key].id
  group_owner_object_ids     = var.group_owner_object_ids
  roles                      = var.roles
}
