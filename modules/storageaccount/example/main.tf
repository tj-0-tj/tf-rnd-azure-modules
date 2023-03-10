locals {
  org         = "org"
  ou          = "rnd"
  environment = "dev"
  location    = "uksouth"

  resource_name = format("%s-%s-%s", local.org, local.ou, local.environment)
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${local.resource_name}-rg-1"
  location = local.location
}

module "storageaccount" {
  source = "../../modules/storageaccount"

  resource_group_name     = azurerm_resource_group.resourcegroup.name
  resource_group_location = azurerm_resource_group.resourcegroup.location
  assetname               = local.assetname
  environment             = local.environment
  instance_count          = 1

}