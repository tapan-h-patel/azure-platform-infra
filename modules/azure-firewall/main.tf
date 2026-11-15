resource "azurerm_public_ip" "firewall_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}
resource "azurerm_firewall_policy" "firewall_policy" {
  name                     = var.policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku_tier
  threat_intelligence_mode = var.threat_intelligence_mode
  tags                     = var.tags
}
resource "azurerm_firewall" "firewall" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id
  zones               = var.zones
  tags                = var.tags
  ip_configuration {
    name                 = "firewall"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }
}
resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  for_each           = length(var.network_rule_collections) > 0 ? { configured = true } : {}
  name               = "network-rules"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 100
  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections
    content {
      name     = network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action
      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.key
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }
}
