terraform {
  backend "azurerm" {
    resource_group_name  = "rg-mgmt-uks-01"
    storage_account_name = "sagregmgmtuks01"
    container_name       = "tfstate"
    key                  = "fileshare-dev.tfstate"
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
  subscription_id = "1e657656-e544-4315-8799-7c680936d1d0"
}

provider "azuread" {}

provider "azapi" {}