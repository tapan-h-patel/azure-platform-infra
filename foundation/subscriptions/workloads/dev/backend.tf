terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-shared-uks-001"
    storage_account_name = "sttfstateshareduksplt001"
    container_name       = "tfstate"
    key                  = "azlab/foundation/subscriptions/workloads/dev.tfstate"
    tenant_id            = "846732b8-d571-413b-81e7-4952884e0bb9"
    subscription_id      = "362fd75d-bba6-4016-9df8-e2f783081d58"
    use_azuread_auth     = true
    use_cli              = true
  }
}
