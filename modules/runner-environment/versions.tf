terraform {
  required_version = ">= 1.17.2, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.14.0, < 6.0.0"
    }
  }
}
