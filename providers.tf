terraform {
  required_version = "~> 1.4.0"
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate31235"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}