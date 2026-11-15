variable "name" {
  description = "Stable tenant-unique management group name."
  type        = string
}
variable "display_name" {
  description = "Friendly management group name."
  type        = string
}
variable "parent_management_group_id" {
  description = "Full existing or newly created parent ID."
  type        = string
}
variable "access_name" {
  description = "Naming token for scoped security groups."
  type        = string
}
variable "group_owner_object_ids" {
  description = "Privileged owners of the scoped access groups."
  type        = set(string)
}
variable "roles" {
  description = "Access group suffix to Azure role mapping."
  type        = map(string)
  default     = { reader = "Reader", contributor = "Contributor", owner = "Owner" }
}
