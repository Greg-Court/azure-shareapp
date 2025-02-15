terraform {
  backend "azurerm" {
    resource_group_name  = "rg-mgmt-uks-01"
    storage_account_name = "sagregmgmtuks01"
    use_azuread_auth     = true
    container_name       = "tfstate"
  }

  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "azapi" {}