locals {
  org         = var.org
  ou          = var.ou
  environment = var.environment
  location    = var.location
  rg_name     = "${var.location}-${local.org}-${local.ou}-${local.environment}-rg-1"
}

########### Management ###########

resource "azurerm_resource_group" "resourcegroup" {
  name     = local.rg_name
  location = local.location
}

########### Secrets  ###########

module "key_vault" {
  source = "./modules/key_vault"

  assetname           = "kv-ci-gh"
  environment         = local.environment
  location            = local.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  depends_on = [
    azurerm_resource_group.resourcegroup
  ]
}