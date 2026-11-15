variable "tenant_id" {
  description = "Target Microsoft Entra tenant ID."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "Provide a valid tenant UUID."
  }
}

variable "subscription_id" {
  description = "Target Azure subscription ID."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "Provide a valid subscription UUID."
  }
}

variable "location" {
  description = "Azure location, for example uksouth."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]+$", var.location))
    error_message = "Use an Azure location token without spaces."
  }
}

variable "naming" {
  description = "Stable naming components; suffix must make the account globally unique."
  type = object({
    workload    = string
    environment = string
    region      = string
    instance    = string
    suffix      = string
  })
  validation {
    condition = alltrue([
      for value in [var.naming.workload, var.naming.environment, var.naming.region, var.naming.suffix] :
      can(regex("^[a-z][a-z0-9]*$", value))
    ]) && can(regex("^[0-9]{3}$", var.naming.instance))
    error_message = "Naming tokens must start with a lowercase letter and contain lowercase letters/digits; instance must have three digits."
  }
  validation {
    condition     = length("st${var.naming.workload}${var.naming.environment}${var.naming.region}${var.naming.suffix}") <= 24
    error_message = "The generated storage account name must fit within 24 characters."
  }
}

variable "allowed_public_ipv4_addresses" {
  description = "Explicit public IPv4 addresses allowed through the storage firewall (no CIDR suffix). Include the operator's egress IP."
  type        = set(string)
  validation {
    condition = length(var.allowed_public_ipv4_addresses) > 0 && alltrue([
      for ip in var.allowed_public_ipv4_addresses :
      can(cidrnetmask("${ip}/32")) && !strcontains(ip, "/")
    ])
    error_message = "Supply at least one valid IPv4 address without a CIDR suffix; use public egress addresses only."
  }
}

variable "state_group_object_ids" {
  description = "Entra security group object IDs granted Storage Blob Data Contributor on the state container. Operators must be members of an authorized group."
  type        = set(string)
  validation {
    condition = length(var.state_group_object_ids) > 0 && alltrue([
      for id in var.state_group_object_ids :
      can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Supply at least one valid Entra security group object UUID."
  }
}

variable "replication_type" {
  description = "State storage replication; validate regional availability and cost before deployment."
  type        = string
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Choose a supported Azure Storage replication type."
  }
}

variable "tags" {
  description = "Additional tags, for example owner and cost centre; mandatory baseline tags take precedence."
  type        = map(string)
}
