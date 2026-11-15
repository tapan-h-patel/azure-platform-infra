resource "azurerm_virtual_network" "runner_network" {
  name                = "vnet-runners-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.address_space]
  tags                = var.tags
}
resource "azurerm_subnet" "container_apps" {
  name                 = "snet-runners-${var.name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.runner_network.name
  address_prefixes     = [var.container_apps_subnet_cidr]
  delegation {
    name = "container-apps"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-private-endpoints-${var.name}"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.runner_network.name
  address_prefixes                  = [var.private_endpoints_subnet_cidr]
  private_endpoint_network_policies = "Disabled"
}
resource "azurerm_private_dns_zone" "blob_storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "runner_network" {
  name                 = "link-runners-${var.name}"
  private_dns_zone_id  = azurerm_private_dns_zone.blob_storage.id
  virtual_network_id   = azurerm_virtual_network.runner_network.id
  registration_enabled = false
  tags                 = var.tags
}
resource "azurerm_private_endpoint" "state_storage" {
  name                = "pe-tfstate-blob-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-tfstate-blob-${var.name}"
    private_connection_resource_id = var.state_storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_storage.id]
  }
}
