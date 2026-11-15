provider "azurerm" {
  features {
    subscription {
      prevent_cancellation_on_destroy = true
    }
  }
  tenant_id                       = var.tenant_id
  subscription_id                 = var.deployment_subscription_id
  resource_provider_registrations = "none"
}
