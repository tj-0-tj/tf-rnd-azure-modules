
##################################################################################
# Key vault module
##################################################################################

resource "random_id" "server" {
  byte_length = 2
}

locals {
  unique_id = "${random_id.server.hex}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "shared_key_vault" {
  name                = "${var.appname}-kv-${var.environment}-${local.unique_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.key_vault_tenant_id
  sku_name = "standard"
  soft_delete_retention_days = 7

  access_policy {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id

      key_permissions = [
        "Get",
        "List",
        "Create",
        "Delete",
        "Purge",
        "Recover"
      ]

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge",
        "Recover"
      ]

      certificate_permissions = [
        "Get",
        "List",
        "Import",
        "Delete",
        "Purge",
        "Recover"
      ]
  }

  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}
