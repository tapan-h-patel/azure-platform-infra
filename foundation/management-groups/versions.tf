terraform {
  required_version = "= 1.17.2"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.9.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 5.14.0"
    }
  }
}
