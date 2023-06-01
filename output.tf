output "current_oid" {
  value = data.azurerm_client_config.current.object_id
}
output "ci_service_endpoint" {
  value = data.azuread_service_principal.ci_service_principle.object_id
}