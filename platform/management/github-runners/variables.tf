variable "tenant_id" {
  description = "Customer Entra tenant ID."
  type        = string
}
variable "subscription_id" {
  description = "Target infrastructure subscription ID."
  type        = string
}
variable "location" {
  description = "Azure location."
  type        = string
}
variable "environment_name" {
  description = "Explicit Container Apps environment name from terraform.tfvars."
  type        = string
}
variable "tags" {
  description = "Complete resource tags supplied in terraform.tfvars, including managed_by and repository."
  type        = map(string)
}
variable "infrastructure_subnet_id" {
  description = "Explicit output from the runner-network root in the same subscription and region."
  type        = string
}

variable "resource_group_name" {
  description = "Explicit resource group name from deployment configuration."
  type        = string
}
