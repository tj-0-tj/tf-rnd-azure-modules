variable "ado_vg_name" {
  type = string
}

variable "ado_project_name" {
  type = string
}


variable "environment" {
  type = string
}

variable "department" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "secret_maps" {
  type    = map(string)
  default = {}
}

variable "keyvault_readonly_access_object_ids" {
  type    = list(string)
  default = []
}

variable "keyvault_admin_access_object_ids" {
  type    = list(string)
  default = []
}

variable "keyvault_devs_access_object_ids" {
  type    = list(string)
  default = []
}

variable "ci_service_principle" {
  type = string
}

### aks

variable "kubernetes_version" {
  default = "1.25"
}

variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}
