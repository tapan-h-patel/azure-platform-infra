module "subscriptions" {
  source   = "../../../modules/subscription-vending"
  for_each = var.subscriptions

  alias               = each.value.alias
  subscription_name   = each.value.subscription_name
  billing_scope_id    = each.value.billing_scope_id
  management_group_id = each.value.management_group_id
  workload            = each.value.workload
  tags                = each.value.tags
  expected_tenant_id  = var.subscription_tenant_id
}
