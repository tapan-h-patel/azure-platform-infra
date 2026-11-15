output "id" { value = azurerm_route_table.route_table.id }

output "associated_subnet_ids" { value = { for key, association in azurerm_subnet_route_table_association.subnet_association : key => association.subnet_id } }
output "routes" { value = { for key, route in azurerm_route.route : key => { prefix = route.address_prefix, next_hop_ip = route.next_hop_in_ip_address, next_hop_type = route.next_hop_type } } }
