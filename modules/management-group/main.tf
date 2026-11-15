resource "azurerm_management_group" "management_group" {
  name                       = var.name
  display_name               = var.display_name
  parent_management_group_id = var.parent_management_group_id
}

# Do not also set subscription_ids on the management group resource: the two
# ownership models conflict. Each subscription must have exactly one owner.
resource "azurerm_management_group_subscription_association" "subscription_association" {
  for_each = var.subscription_ids

  management_group_id = azurerm_management_group.management_group.id
  subscription_id     = "/subscriptions/${each.value}"
}
