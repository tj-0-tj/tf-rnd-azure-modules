data "azuredevops_project" "ado_project" {
  name = var.ado_project_name
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

data "azuread_service_principal" "ci_service_principle" {
  display_name = "tj0798-CAIS-7eac40a0-6807-4898-9a66-fbe5bba26ace"
}