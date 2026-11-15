variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_name" { type = string }
variable "remote_virtual_network_id" { type = string }
variable "allow_forwarded_traffic" { type = bool }
variable "allow_gateway_transit" { type = bool }
variable "use_remote_gateways" { type = bool }
variable "allow_virtual_network_access" { type = bool }
