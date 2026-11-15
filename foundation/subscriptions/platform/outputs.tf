output "subscriptions" {
  description = "New subscription IDs, names, tenant, alias and management group placement keyed by platform area."
  value = { for area, subscription in module.subscriptions : area => {
    subscription_id          = subscription.subscription_id
    subscription_resource_id = subscription.subscription_resource_id
    alias_resource_id        = subscription.alias_resource_id
    subscription_name        = subscription.subscription_name
    management_group_id      = subscription.management_group_id
    tenant_id                = subscription.tenant_id
  } }
}
