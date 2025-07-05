terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.32.0"
    }
  }
}

provider "azurerm" {
  features {
      }
      subscription_id = "04d7b42e-3695-4467-a1a1-d8c269a4c3c1"
}