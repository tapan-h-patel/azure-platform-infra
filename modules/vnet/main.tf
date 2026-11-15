locals {
  vnet_ranges = [for prefix in var.address_space : {
    first = try(sum([for i, octet in split(".", cidrhost(prefix, 0)) : tonumber(octet) * pow(256, 3 - i)]), -1)
    last  = try(sum([for i, octet in split(".", cidrhost(prefix, -1)) : tonumber(octet) * pow(256, 3 - i)]), -1)
  }]
  subnet_ranges = flatten([for subnet in values(var.subnets) : [for prefix in subnet.address_prefixes : {
    first = try(sum([for i, octet in split(".", cidrhost(prefix, 0)) : tonumber(octet) * pow(256, 3 - i)]), -1)
    last  = try(sum([for i, octet in split(".", cidrhost(prefix, -1)) : tonumber(octet) * pow(256, 3 - i)]), -1)
  }]])
}
resource "azurerm_virtual_network" "virtual_network" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
  lifecycle {
    precondition {
      condition     = alltrue([for subnet in local.subnet_ranges : anytrue([for network in local.vnet_ranges : subnet.first >= network.first && subnet.last <= network.last])])
      error_message = "Every subnet prefix must fit inside a VNet address range."
    }
    precondition {
      condition     = alltrue(flatten([for i, left in local.subnet_ranges : [for j, right in local.subnet_ranges : i == j || left.last < right.first || right.last < left.first]]))
      error_message = "Subnet prefixes must not overlap."
    }
  }
}
resource "azurerm_subnet" "subnet" {
  for_each                          = var.subnets
  name                              = each.value.name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.virtual_network.name
  address_prefixes                  = each.value.address_prefixes
  default_outbound_access_enabled   = each.value.default_outbound_access_enabled
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}
