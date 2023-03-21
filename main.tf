##################################################################################
# Key vault module
##################################################################################

resource "random_id" "server" {
  byte_length = 2
}

locals {
  unique_id = random_id.server.hex
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "shared_key_vault" {
  name                       = "kv-ci-${var.environment}-${local.unique_id}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

}


resource "azurerm_key_vault_access_policy" "az_kv_ap_tf" {
  key_vault_id = azurerm_key_vault.shared_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", 
    "Get", "Import", "List", "Purge", "Recover", "Restore", 
    "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", 
    "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore" , "Set"
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

data "azuread_service_principal" "ado_sp" {
  display_name = "tj0798-CAIS-7eac40a0-6807-4898-9a66-fbe5bba26ace"
}

resource "azurerm_key_vault_access_policy" "az_kv_ap_ci" {
  key_vault_id = azurerm_key_vault.shared_key_vault.id
  tenant_id    = data.azuread_service_principal.ado_sp.application_tenant_id
  object_id    = data.azuread_service_principal.ado_sp.object_id

  secret_permissions = [
    "List", "Set", "Get"
  ]

  certificate_permissions = [
    "Create", "List", "Get"
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
}

# Role for terraform ci, required for creating secrets
# resource "azurerm_role_assignment" "terraform" {
#   principal_id         = data.azurerm_client_config.current.object_id
#   scope                = azurerm_key_vault.shared_key_vault.id
#   role_definition_name = "Terraform Key Vault Administrator"
#   depends_on           = [azurerm_key_vault.shared_key_vault]
# }


##################################################################################
# ADO Variable Groups
##################################################################################

data "azuredevops_project" "ado_project" {
  name = var.ado_project_name
}

data "azuredevops_serviceendpoint_azurerm" "service_endpoint" {
  project_id          = data.azuredevops_project.ado_project.id
  service_endpoint_id = var.ado_sp_endpoint_id
}

resource "azuredevops_variable_group" "ci_vg" {
  project_id   = data.azuredevops_project.ado_project.id
  name         = "vg-ci-${var.department}-${var.environment}-${local.unique_id}"
  description  = "CI Variable Group"
  allow_access = true

  key_vault {
    name                = azurerm_key_vault.shared_key_vault.name
    service_endpoint_id = data.azuredevops_serviceendpoint_azurerm.service_endpoint.id
  }

  dynamic "variable" {
    for_each = var.secret_maps
    content {
      name = variable.key
    }
  }
  depends_on = [
    azurerm_key_vault_access_policy.az_kv_ap_ci
  ]
}