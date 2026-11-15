output "hub_vnet_id" { value = module.hub_spoke.hub_vnet_id }
output "spoke_vnet_ids" { value = module.hub_spoke.spoke_vnet_ids }
output "subnet_ids" { value = module.hub_spoke.subnet_ids }
output "firewall_private_ip" { value = module.hub_spoke.firewall_private_ip }
output "firewall_policy_id" { value = module.hub_spoke.firewall_policy_id }
