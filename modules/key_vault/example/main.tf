locals {
  environment = var.environment
  location    = var.location
}

##################################################################################
# RESOURCES
##################################################################################

resource "azurerm_resource_group" "shared" {
  name     = "${var.appname}-shared-rg-${var.environment}"
  location = var.location
  tags = {
    environment = var.environment
    department  = var.department
    appname     = var.appname
  }
}

##################################################################################
# Secrets
##################################################################################

module "key_vault" {
  source = "./modules/key_vault"

  key_vault_tenant_id      = data.azurerm_client_config.current.tenant_id
  appname                  = var.appname
  environment              = var.environment
  resource_group_name      = azurerm_resource_group.shared.name
  location                 = azurerm_resource_group.shared.location

  depends_on = [
    azurerm_resource_group.shared
  ]
}
