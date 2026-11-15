variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "dns_servers" { type = list(string) }
variable "address_space" {
  type = list(string)
  validation {
    condition     = length(var.address_space) > 0 && alltrue([for prefix in var.address_space : can(cidrnetmask(prefix))])
    error_message = "Supply at least one IPv4 VNet CIDR."
  }
}
variable "subnets" {
  type = map(object({
    name                              = string
    address_prefixes                  = list(string)
    default_outbound_access_enabled   = bool
    private_endpoint_network_policies = string
  }))
  validation {
    condition     = alltrue([for subnet in values(var.subnets) : length(subnet.address_prefixes) > 0 && alltrue([for prefix in subnet.address_prefixes : can(cidrnetmask(prefix))]) && contains(["Enabled", "Disabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], subnet.private_endpoint_network_policies)])
    error_message = "Each subnet needs IPv4 prefixes and a valid private endpoint network policy mode."
  }
  validation {
    condition     = length(distinct([for subnet in values(var.subnets) : subnet.name])) == length(var.subnets)
    error_message = "Subnet names must be unique within the VNet."
  }
}
