data "azuredevops_project" "ado_project" {
  name = var.ado_project_name
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# data "azuread_service_principal" "ci_service_principle" {
#   display_name = var.ci_service_principle
# }

data "azurerm_resource_group" "myrg" {
  name = "myrg"
}