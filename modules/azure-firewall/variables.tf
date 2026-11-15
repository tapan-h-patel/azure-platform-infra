variable "name" { type = string }
variable "policy_name" { type = string }
variable "public_ip_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }
variable "tags" { type = map(string) }
variable "zones" { type = list(string) }
variable "sku_tier" {
  type = string
  validation {
    condition     = contains(["Standard", "Premium"], var.sku_tier)
    error_message = "This VNet firewall module supports Standard or Premium; Basic needs a separate management subnet design."
  }
}
variable "threat_intelligence_mode" {
  type = string
  validation {
    condition     = contains(["Alert", "Deny"], var.threat_intelligence_mode)
    error_message = "Use Alert or Deny."
  }
}
variable "network_rule_collections" {
  description = "Explicit IP/service-tag network rules. Empty means default deny; no DNAT or application rules are created."
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      protocols             = list(string)
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
    }))
  }))
  validation {
    condition     = alltrue([for collection in values(var.network_rule_collections) : contains(["Allow", "Deny"], collection.action) && collection.priority >= 100 && collection.priority <= 65000 && length(collection.rules) > 0])
    error_message = "Collections need Allow/Deny, priority 100-65000, and at least one rule."
  }
}
