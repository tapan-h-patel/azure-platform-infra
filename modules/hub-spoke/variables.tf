variable "hub" {
  type = object({
    resource_group_name  = string
    virtual_network_name = string
    address_space        = list(string)
    dns_servers          = list(string)
    route_table_name     = string
    tags                 = map(string)
    subnets = map(object({
      name                              = string
      address_prefixes                  = list(string)
      default_outbound_access_enabled   = bool
      private_endpoint_network_policies = string
      route_via_hub                     = bool
    }))
  })
}
variable "spokes" {
  type = map(object({
    resource_group_name  = string
    virtual_network_name = string
    address_space        = list(string)
    dns_servers          = list(string)
    route_table_name     = string
    tags                 = map(string)
    subnets = map(object({
      name                              = string
      address_prefixes                  = list(string)
      default_outbound_access_enabled   = bool
      private_endpoint_network_policies = string
      route_via_hub                     = bool
    }))
    hub_to_spoke_peering_name = string
    spoke_to_hub_peering_name = string
  }))
  validation {
    condition     = length(var.spokes) > 0
    error_message = "Configure at least one spoke."
  }
}
variable "location" { type = string }
variable "transit_routes" {
  description = "Additional destination-prefix map routed through the firewall. Must include a default route; include private summaries for destinations outside managed VNets."
  type        = map(string)
  validation {
    condition     = contains(values(var.transit_routes), "0.0.0.0/0") && alltrue([for prefix in values(var.transit_routes) : can(cidrnetmask(prefix))])
    error_message = "Supply IPv4 route prefixes including 0.0.0.0/0."
  }
}
variable "firewall" {
  type = object({
    name                     = string
    policy_name              = string
    public_ip_name           = string
    subnet_key               = string
    sku_tier                 = string
    zones                    = list(string)
    threat_intelligence_mode = string
    network_rule_collections = map(object({
      priority = number
      action   = string
      rules    = map(object({ protocols = list(string), source_addresses = list(string), destination_addresses = list(string), destination_ports = list(string) }))
    }))
  })
  validation {
    condition     = try(var.hub.subnets[var.firewall.subnet_key].name == "AzureFirewallSubnet" && !var.hub.subnets[var.firewall.subnet_key].route_via_hub && length(var.hub.subnets[var.firewall.subnet_key].address_prefixes) == 1 && tonumber(split("/", var.hub.subnets[var.firewall.subnet_key].address_prefixes[0])[1]) <= 26, false)
    error_message = "Select an AzureFirewallSubnet with one /26-or-larger prefix and route_via_hub=false."
  }
}
