output "current_oid" {
  value = data.azurerm_client_config.current.object_id
}

output "host" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.host
}

output "client_key" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive = true
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.password
}