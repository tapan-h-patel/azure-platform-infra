output "id" { value = azurerm_virtual_network_peering.virtual_network_peering.id }

output "configuration" {
  value = {
    local_vnet_name   = azurerm_virtual_network_peering.virtual_network_peering.virtual_network_name
    remote_vnet_id    = azurerm_virtual_network_peering.virtual_network_peering.remote_virtual_network_id
    forwarded_traffic = azurerm_virtual_network_peering.virtual_network_peering.allow_forwarded_traffic
    gateway_transit   = azurerm_virtual_network_peering.virtual_network_peering.allow_gateway_transit
    remote_gateway    = azurerm_virtual_network_peering.virtual_network_peering.use_remote_gateways
  }
}
