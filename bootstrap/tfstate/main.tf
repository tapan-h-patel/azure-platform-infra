module "tfstate_storage" {
  source                        = "../../modules/tfstate-storage"
  tenant_id                     = var.tenant_id
  subscription_id               = var.subscription_id
  location                      = var.location
  naming                        = var.naming
  allowed_public_ipv4_addresses = var.allowed_public_ipv4_addresses
  state_group_object_ids        = var.state_group_object_ids
  replication_type              = var.replication_type
  tags                          = var.tags
}
