terraform {
  required_version = "~> 1.4.2"
  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstate31235"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.47.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {
    # key_vault {
    #   purge_soft_delete_on_destroy    = true
    #   recover_soft_deleted_key_vaults = true
    # }
  }
}

# export AZDO_PERSONAL_ACCESS_TOKEN=xxxx
# export AZDO_ORG_SERVICE_URL=https://dev.azure.com/tj0798
provider "azuredevops" {

}