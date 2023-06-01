##################################################################################
# Key vault module
##################################################################################

resource "random_id" "server" {
  byte_length = 2
}

locals {
  unique_id = random_id.server.hex
}



resource "azurerm_key_vault" "shared_key_vault" {
  name                       = "kv-ci-${var.environment}-${local.unique_id}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

}


resource "azurerm_key_vault_access_policy" "admin_access_policy" {
  for_each     = toset(concat(var.keyvault_admin_access_object_ids, [data.azurerm_client_config.current.object_id]))
  key_vault_id = azurerm_key_vault.shared_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt",
    "Get", "Import", "List", "Purge", "Recover", "Restore",
    "Sign", "UnwrapKey", "Update", "Verify", "WrapKey",
    "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get",
    "GetIssuers", "Import", "List", "ListIssuers",
    "ManageContacts", "ManageIssuers", "Purge",
    "Recover", "Restore", "SetIssuers", "Update"
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS",
    "List", "ListSAS", "Purge", "Recover", "RegenerateKey",
    "Restore", "Set", "SetSAS", "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "devs_access_policy" {
  for_each     = toset(var.keyvault_devs_access_object_ids)
  key_vault_id = azurerm_key_vault.shared_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  secret_permissions = [
    "List", "Set", "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "readonly_access_policy" {
  for_each     = toset(concat(var.keyvault_readonly_access_object_ids))
  key_vault_id = azurerm_key_vault.shared_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  secret_permissions = [
    "List", "Get"
  ]

}

##################################################################################
# Key vault Secrets
##################################################################################


resource "azurerm_key_vault_secret" "ci_secrets" {
  count        = length(var.secret_maps)
  name         = keys(var.secret_maps)[count.index]
  value        = values(var.secret_maps)[count.index]
  key_vault_id = azurerm_key_vault.shared_key_vault.id
  depends_on = [
    azurerm_key_vault.shared_key_vault,
    azurerm_key_vault_access_policy.admin_access_policy
  ]
}

# Role for terraform ci, required for creating secrets
# resource "azurerm_role_assignment" "admin" {
#   principal_id         = data.azurerm_client_config.current.object_id
#   scope                = azurerm_key_vault.shared_key_vault.id
#   role_definition_name = "Key Vault Administrator"
#   depends_on           = [azurerm_key_vault.shared_key_vault]
# }


##################################################################################
# ADO Variable Groups
##################################################################################

# resource "azuredevops_serviceendpoint_azurerm" "ci_service_endpoint" {
#   project_id                = data.azuredevops_project.ado_project.id
#   service_endpoint_name     = "gsk-rd-ci-${var.environment}"
#   azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#   azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
#   azurerm_subscription_name = data.azurerm_subscription.current.display_name
# }

# resource "azuredevops_variable_group" "ci_vg" {
#   project_id   = data.azuredevops_project.ado_project.id
#   name         = "vg-ci-${var.department}-${var.environment}-${local.unique_id}"
#   description  = "CI Variable Group"
#   allow_access = true

#   key_vault {
#     name                = azurerm_key_vault.shared_key_vault.name
#     service_endpoint_id = azuredevops_serviceendpoint_azurerm.ci_service_endpoint.id
#   }

#   dynamic "variable" {
#     for_each = var.secret_maps
#     content {
#       name = variable.key
#     }
#   }
#   depends_on = [
#     azurerm_key_vault_access_policy.readonly_access_policy,
#     azuredevops_serviceendpoint_azurerm.ci_service_endpoint
#   ]
# }
