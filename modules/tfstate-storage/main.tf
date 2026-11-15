locals {
  resource_group_name  = "rg-${var.naming.workload}-${var.naming.environment}-${var.naming.region}-${var.naming.instance}"
  storage_account_name = "st${var.naming.workload}${var.naming.environment}${var.naming.region}${var.naming.suffix}"
  tags = merge(var.tags, {
    workload    = var.naming.workload
    environment = var.naming.environment
    managed_by  = "terraform"
    repository  = "azure-platform-infra"
  })
}

module "resource_group" {
  source   = "../resource-group"
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = local.storage_account_name
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = var.replication_type
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false
  public_network_access           = "Enabled"
  tags                            = local.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    ip_rules       = var.allowed_public_ipv4_addresses
  }

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_role_assignment" "tfstate_access" {
  for_each             = var.state_group_object_ids
  scope                = azurerm_storage_container.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

