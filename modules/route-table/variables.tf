variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "bgp_route_propagation_enabled" { type = bool }
variable "next_hop_ip_address" { type = string }
variable "routes" { type = map(string) }
variable "subnet_ids" { type = map(string) }
